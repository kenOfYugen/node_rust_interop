#![feature(test)]

extern crate rayon;
use rayon::prelude::*;

mod prng;
use prng::{PRNG, FloatPointsIterator};

pub fn estimate(points: f64) -> f64 {
  let mut inside: f64 = 0.;
  let randseed = 1.;

  let mut generator = PRNG::new(randseed);

  for _ in 0..points as usize {
    let x = generator.next_float();
    let y = generator.next_float();

    if (x * x) + (y * y) <= 1. {
      inside += 1.;
    }
  }

  inside / points * 4.
}

pub fn functional_estimate(points: f64) -> f64 {
  let randseed = 1.;

  let inside = FloatPointsIterator::new(randseed)
    .take(points as usize)
    .map(|(x,y)| (x * x) + (y * y))
    .filter(|&point| point <= 1.)
    .fold(0., |acc, _| acc + 1.);

  inside / points * 4.
}

pub fn ws_estimate(points: f64) -> f64 {
  let chunks = 16;
  let total = (1..chunks + 1)
    .into_par_iter()
    .map(|chunk| {
      FloatPointsIterator::new(chunk as f64)
        .take((points / chunks as f64) as usize)
        .map(|(x,y)| (x * x) + (y * y))
        .filter(|&point| point <= 1.)
        .fold(0., |acc, _| acc + 1.)
    })
    .map(|inside| inside / points * 4.)
    .reduce_with(std::ops::Add::add);

  total.unwrap()
}

#[cfg(test)]
mod estimate_tests {
  use estimate;

  #[test]
  fn pi_estimation_test() {
    let pi = estimate(1e6);
    assert!((pi > 2.64) && (pi < 3.64), "estimated pi value is more than 0.5 off");
  }

  use ws_estimate;

  #[test]
  fn ws_estimation_test() {
    let pi = ws_estimate(1e6);
    assert!((pi > 2.64) && (pi < 3.64), "estimated pi value is more than 0.5 off");
  }
}

#[cfg(test)]
mod estimate_benchmarks {
  extern crate test;
  use self::test::Bencher;

  use estimate;

  #[bench]
  fn pi_estimation_bench(b: &mut Bencher) {
    b.iter(|| {
      estimate(1e6)
    });
  }

  use functional_estimate;
  #[bench]
  fn functional_estimate_bench(b: &mut Bencher) {
    b.iter(|| {
      functional_estimate(1e6)
    });
  }

  use ws_estimate;
  #[bench]
  fn ws_estimate_bench(b: &mut Bencher) {
    b.iter(|| {
      ws_estimate(1e6)
    });
  }
}
