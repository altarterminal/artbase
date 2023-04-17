use std::io::{
    BufRead,
    BufReader,
};

use std::time::{
    Duration,
    Instant,
};

use std::thread::sleep;

use clap::Parser;

struct Param
{
    reader:   Box<dyn BufRead>,
    msec:     u32,
    height:   u32,
    initwait: u32,
}

// ###################################################################
// パラメータ
// ###################################################################

#[derive(Debug,Parser)]
pub struct Arg
{
    #[clap(short='r', long="row")]
    height: u32,

    #[clap(short='m', long="msec")]
    msec: u32,

    #[clap(short='w', long="wait", default_value="0")]
    initwait: u32,

    filename: Option<String>,
}

// ###################################################################
// 時間
// ###################################################################

pub struct Time
{
    instant: Instant,
}

impl Time {
    fn start_time(&mut self) {
        self.instant = Instant::now();
    }

    fn end_time(&mut self) -> (u32, u32) {
        let durtime = self.instant.elapsed();

        let sec  = durtime.as_secs().try_into().unwrap();
        let msec = durtime.as_millis().try_into().unwrap();

        (sec, msec)
    }

    fn wait_msec(msec: u32) {
        if msec > 0 {
            sleep(Duration::from_millis(msec.into()));
        }
    }
}

// ###################################################################
// ユーティリティ
// ###################################################################

fn eprint_exit(
    emsg: &str,
    en:   i32,
) -> !
{
    // プログラム名とメッセージを表示
    let args = std::env::args().collect::<Vec<String>>();
    let procname = &args[0];
    eprintln!("{}: {}", procname, emsg);

    // 指定のコードで異常終了
    std::process::exit(en);
}
    
fn get_param() -> Param
{
    // 引数を取得
    let arg = Arg::parse();
    let height   = arg.height;
    let msec     = arg.msec;
    let initwait = arg.initwait;
    let filename = arg.filename;

    let reader = match filename {
        Some(filename) => {
            // 通常ファイルを指定された場合
            
            // ファイルが正常にオープンできなければエラー終了
            let fileres = std::fs::File::open(filename);
            if let Err(_) = fileres {
                eprint_exit("cannot open file", 10);
            }
            
            let file = fileres.unwrap();
            Box::new(BufReader::new(file)) as Box<dyn BufRead>
        },
        None => {
            // 標準入力を指定された場合
            
            let file = std::io::stdin();
            Box::new(BufReader::new(file)) as Box<dyn BufRead>
        },
    };

    Param { reader, msec, height, initwait }
}

fn output_oneframe(
    reader: &mut Box<dyn BufRead>,
    height: u32,
) -> bool
{
    let mut cntline = 0;
    let mut line = String::new();

    while cntline < height {
        // 入力を一行だけ読み込む
        let readres = reader.read_line(&mut line);
        
        match readres {
            // EOFに到達
            Ok(0)  => return false,
            // 読み込みに成功
            Ok(_)  => print!("{}", line),
            // 読み込みに失敗
            Err(_) => eprint_exit("read a line failed", 20),
        }

        // 現在読み込んだ行は破棄
        line.clear();

        // 読み込んだ行数をカウントアップ
        cntline = cntline + 1;
    }

    true
}

// ###################################################################
// 本体処理
// ###################################################################

fn main()
{
    // ===============================================================
    // 前処理
    // ===============================================================

    // パラメータをパース
    let Param { mut reader, msec, height, initwait } = get_param();

    // ===============================================================
    // 本体処理
    // ===============================================================

    // 時間計測用のオブジェクトを用意
    let mut time = Time { instant: Instant::now() };

    // 待機を実施
    Time::wait_msec(initwait);
    
    loop {
        // 開始時刻（基準）を保存
        time.start_time();

        // 入力が存在する限り出力を実行
        if ! output_oneframe(&mut reader, height) { break; }

        // 出力処理の経過時間を取得
        let (dursec, durmsec) = time.end_time();

        // 待機時間を計算
        let waittime =
            if dursec > 0 || durmsec > msec {
                0u32
            } else {
                (msec - durmsec).try_into().unwrap()
            };
        
        // 待機
        Time::wait_msec(waittime);
    }
}
