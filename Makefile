CXX=g++
CXXFLAGS=-std=c++17 -Wall -O3 -fopenmp -msse4.1
LDFLAGS=-lm -lz

cpp_source=sequence_batch.cc index.cc minimizer_generator.cc candidate_processor.cc alignment.cc feature_barcode_matrix.cc ksw.cc draft_mapping_generator.cc mapping_generator.cc mapping_writer.cc chromap.cc chromap_driver.cc
src_dir=src
objs_dir=objs
objs+=$(patsubst %.cc,$(objs_dir)/%.o,$(cpp_source))

exec=chromap

ifneq ($(asan),)
	CXXFLAGS+=-fsanitize=address -g
	LDFLAGS+=-fsanitize=address -ldl -g
endif

all: dir $(exec) 
	
dir:
	mkdir -p $(objs_dir)

$(exec): $(objs)
	$(CXX) $(CXXFLAGS) $(objs) -o $(exec) $(LDFLAGS)
	
$(objs_dir)/%.o: $(src_dir)/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	-rm -rf $(exec) $(objs_dir) test_build

test_build_dir=test_build
test_exec=$(test_build_dir)/run_tests
test_src_dir=test
gtest_dir=test/gtest

test_source=main.cc test_minimizer_generator.cc test_index.cc
test_objs+=$(patsubst %.cc,$(test_build_dir)/%.o,$(test_source))

GTEST_CXXFLAGS=-isystem $(gtest_dir)/googletest/include -I$(gtest_dir)/googletest -I$(src_dir) -pthread
GTEST_LDFLAGS=-L$(test_build_dir) -lgtest -pthread

$(test_build_dir)/gtest-all.o: $(gtest_dir)/googletest/src/gtest-all.cc
	$(CXX) $(CXXFLAGS) $(GTEST_CXXFLAGS) -c $< -o $@

$(test_build_dir)/gtest_main.o: $(gtest_dir)/googletest/src/gtest_main.cc
	$(CXX) $(CXXFLAGS) $(GTEST_CXXFLAGS) -c $< -o $@

$(test_build_dir)/libgtest.a: $(test_build_dir)/gtest-all.o
	$(AR) $(ARFLAGS) $@ $^

test: dir $(test_exec)
	echo ">test_seq\nAGTAGCATCG" > test/test_sequence.fa
	$(test_exec)

$(test_exec): $(objs) $(test_objs) $(test_build_dir)/gtest_main.o $(test_build_dir)/libgtest.a
	$(CXX) $(CXXFLAGS) $(GTEST_CXXFLAGS) -o $@ $(filter-out $(objs_dir)/chromap_driver.o $(test_build_dir)/gtest_main.o, $^) $(GTEST_LDFLAGS) $(LDFLAGS)

$(test_build_dir)/%.o: $(test_src_dir)/%.cc
	$(CXX) $(CXXFLAGS) $(GTEST_CXXFLAGS) -c $< -o $@

dir:
	mkdir -p $(objs_dir) $(test_build_dir)
