#include "gtest/gtest.h"
#include "index.h"

TEST(IndexTest, ConstructorAndGetters) {
  chromap::IndexParameters index_parameters;
  index_parameters.kmer_size = 10;
  index_parameters.window_size = 5;
  chromap::Index index(index_parameters);
  EXPECT_EQ(index.GetKmerSize(), 10);
  EXPECT_EQ(index.GetWindowSize(), 5);
}
