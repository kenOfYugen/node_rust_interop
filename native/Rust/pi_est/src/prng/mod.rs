/*
  PRNG implementation
*/
pub struct PRNG {
  seed: f64,
}

impl PRNG {
  pub fn new(seed: f64) -> PRNG {
    let mut seed = seed % 2147483647.;
    if seed <= 0. { seed += 2147483646.; }
    PRNG {seed: seed}
  }

  pub fn next(&mut self) -> f64 {
    self.seed = self.seed * 16807. % 2147483647.;
    self.seed
  }

  pub fn next_float(&mut self) -> f64 {
    (self.next() - 1.) / 2147483646.
  }
}

/*
  Provide iterator interface for (x, y) tuple float generation
*/

pub struct FloatPointsIterator {
  prng: PRNG,
  floats: (f64, f64),
}

impl FloatPointsIterator {
  pub fn new(seed: f64) -> FloatPointsIterator {
    let mut prng = PRNG::new(seed);

    FloatPointsIterator { prng: prng, floats: (0., 0.) }
  }
}

impl Iterator for FloatPointsIterator {
  type Item = (f64, f64);
  fn next(&mut self) -> Option<(f64, f64)> {
    self.floats = (self.prng.next_float(), self.prng.next_float());
    Some(self.floats)
  }
}

#[cfg(test)]
mod prng_tests {

  use prng::PRNG;

  #[test]
  fn integer_generation_test() {
    let mut gen1 = PRNG::new(1.);
    let mut gen2 = PRNG::new(1.);

    let mut first_set: [f64; 10] = [0.; 10];
    let mut second_set: [f64; 10] = [0.; 10];

    for i in 0..10 {
      first_set[i] = gen1.next();
      second_set[i] = gen2.next();
    }

    for i in 0..first_set.len() {
      assert_eq!(first_set[i], second_set[i], "integer generation is not reproducible");
    }
  }

  #[test]
  fn float_generation_test() {
    let mut gen1 = PRNG::new(1.);
    let mut gen2 = PRNG::new(1.);

    let mut first_set: [f64; 10] = [0.; 10];
    let mut second_set: [f64; 10] = [0.; 10];

    for i in 0..10 {
      first_set[i] = gen1.next_float();
      second_set[i] = gen2.next_float();
    }

    for i in 0..10 {
      assert_eq!(first_set[i], second_set[i], "float generation is not reproducible");
    }
  }
}

#[cfg(test)]
mod float_generator_tests {

  use prng::FloatPointsIterator;

  #[test]
  fn float_iterator_test() {
    let mut floats_iterator = FloatPointsIterator::new(1.);
    let some_floats: Vec<(f64, f64)> = floats_iterator.take(5).collect();
    assert_eq!(some_floats.len(), 5);
  }
}

#[cfg(test)]
mod prng_benchmarks {
  extern crate test;
  use self::test::Bencher;

  use prng::PRNG;

  #[bench]
  fn integer_generation_bench(b: &mut Bencher) {
    let mut gen = PRNG::new(1.);
    b.iter(|| {
      gen.next()
    });
  }

  #[bench]
  fn float_generation_bench(b: &mut Bencher) {
    let mut gen = PRNG::new(1.);
    b.iter(|| {
      gen.next_float()
    });
  }

  #[bench]
  fn generate_1e4_floats_bench(b: &mut Bencher) {
    let mut gen = PRNG::new(1.);
    b.iter(|| {
      (0..)
        .take(1e4 as usize)
        .map(|n| gen.next_float())
        .collect::<Vec<f64>>()
    });
  }

  use prng::FloatPointsIterator;

  #[bench]
  fn generate_1e4_floats_iterator_bench(b: &mut Bencher) {
    b.iter(|| {
      FloatPointsIterator::new(1.)
        .take((1e4/2.) as usize)
        .collect::<Vec<(f64, f64)>>()
    });
  }
}
