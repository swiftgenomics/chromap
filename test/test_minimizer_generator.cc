#include "gtest/gtest.h"
#include "minimizer_generator.h"

TEST(MinimizerGeneratorTest, GenerateMinimizers) {
  const int kmer_size = 4;
  const int window_size = 2;
  chromap::MinimizerGenerator minimizer_generator(kmer_size, window_size);

  chromap::SequenceBatch sequence_batch;
  sequence_batch.InitializeLoading("test/test_sequence.fa");
  sequence_batch.LoadAllSequences();
  sequence_batch.FinalizeLoading();

  std::vector<chromap::Minimizer> minimizers;
  minimizer_generator.GenerateMinimizers(sequence_batch, 0, minimizers);

  std::vector<chromap::Minimizer> expected_minimizers;
  expected_minimizers.emplace_back(69, (uint64_t)0 << 33 | (uint64_t)4 << 1 | 1);
  expected_minimizers.emplace_back(16, (uint64_t)0 << 33 | (uint64_t)6 << 1 | 0);
  expected_minimizers.emplace_back(1, (uint64_t)0 << 33 | (uint64_t)8 << 1 | 0);

  EXPECT_EQ(minimizers.size(), expected_minimizers.size());
  for (size_t i = 0; i < minimizers.size(); ++i) {
    EXPECT_EQ(minimizers[i].GetHash(), expected_minimizers[i].GetHash());
    EXPECT_EQ(minimizers[i].GetSequencePosition(),
              expected_minimizers[i].GetSequencePosition());
    EXPECT_EQ(minimizers[i].GetSequenceStrand(),
              expected_minimizers[i].GetSequenceStrand());
  }
}
