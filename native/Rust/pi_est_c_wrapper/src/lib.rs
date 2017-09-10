#![feature(test)]

extern crate pi_est;
use pi_est::{estimate, ws_estimate};

extern crate libc;
use libc::{c_double};

#[no_mangle]
pub extern "C" fn pi_est(points: c_double) -> c_double {
  estimate(points)
}

#[no_mangle]
pub extern "C" fn ws_pi_est(points: c_double) -> c_double {
  ws_estimate(points)
}

#[cfg(test)]
mod pi_est_tests {
  use pi_est;

  #[test]
  fn pi_est_test() {
    let pi = pi_est(1e6);
    assert!((pi > 2.64) && (pi < 3.64), "estimated pi value is more than 0.5 off");
  }

  use ws_pi_est;

  #[test]
  fn ws_pi_est_test() {
    let pi = ws_pi_est(1e6);
    assert!((pi > 2.64) && (pi < 3.64), "estimated pi value is more than 0.5 off");
  }
}

#[cfg(test)]
mod pi_est_benchmarks {
  extern crate test;
  use self::test::Bencher;

  use pi_est;

  #[bench]
  fn pi_est_bench(b: &mut Bencher) {
    b.iter(|| {
      pi_est(1e6)
    });
  }

  use ws_pi_est;

  #[bench]
  fn ws_pi_est_bench(b: &mut Bencher) {
    b.iter(|| {
      ws_pi_est(1e6)
    });
  }
}
