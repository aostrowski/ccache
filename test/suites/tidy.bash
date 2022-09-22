tidy_PROBE() {
    if [ -z "$REAL_TIDY" ]; then
        echo "clang-tidy is not available"
    fi
}

tidy_SETUP() {
    cat <<EOF > test_tidy.cpp
int main() {}
EOF
}

tidy_tests() {
    # -------------------------------------------------------------------------
    TEST "Positive case - no diagnostics"

    tidy_opts_cpp="-checks=*"
    ccache_tidy_cpp="$CCACHE $REAL_TIDY $tidy_opts_cpp --"


    # Run TIDY without CCache
    capture_output RAW_STDOUT RAW_STDERR $REAL_TIDY $tidy_opts_cpp test_tidy.cpp
    expect_equal "" "$RAW_STDOUT"

    # First TIDY run
    capture_output FIRST_STDOUT FIRST_STDERR $ccache_tidy_cpp test_tidy.cpp
    expect_stat preprocessed_cache_hit 0
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$FIRST_STDOUT"
    expect_equal "$RAW_STDERR" "$FIRST_STDERR"

    # Second TIDY run
    capture_output SECOND_STDOUT SECOND_STDERR $ccache_tidy_cpp test_tidy.cpp
    expect_stat preprocessed_cache_hit 1
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$SECOND_STDOUT"
    expect_equal "$RAW_STDERR" "$SECOND_STDERR"

    # -------------------------------------------------------------------------
    TEST "Negative case - some diagnostics"

    tidy_opts_cpp="-checks=*,-modernize-use-trailing-return-type"
    ccache_tidy_cpp="$CCACHE $REAL_TIDY $tidy_opts_cpp --"


    # Run TIDY without CCache
    capture_output RAW_STDOUT RAW_STDERR $REAL_TIDY $tidy_opts_cpp test_tidy.cpp
    expect_equal "" "$RAW_STDOUT"

    # First TIDY run
    capture_output FIRST_STDOUT FIRST_STDERR $ccache_tidy_cpp test_tidy.cpp
    expect_stat preprocessed_cache_hit 0
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$FIRST_STDOUT"
    expect_equal "$RAW_STDERR" "$FIRST_STDERR"

    # Second TIDY run
    capture_output SECOND_STDOUT SECOND_STDERR $ccache_tidy_cpp test_tidy.cpp
    expect_stat preprocessed_cache_hit 1
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$SECOND_STDOUT"
    expect_equal "$RAW_STDERR" "$SECOND_STDERR"

    # -------------------------------------------------------------------------
    TEST "Compilation error"

    tidy_opts_cpp="-checks=* -warnings-as-errors=*"
    ccache_tidy_cpp="$CCACHE $REAL_TIDY $tidy_opts_cpp --"


    # Run TIDY without CCache
    capture_output RAW_STDOUT RAW_STDERR $REAL_TIDY $tidy_opts_cpp test_tidy.cpp
    expect_equal "" "$RAW_STDOUT"

    # First TIDY run
    capture_output FIRST_STDOUT FIRST_STDERR $ccache_tidy_cpp test_tidy.cpp
    expect_stat preprocessed_cache_hit 0
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$FIRST_STDOUT"
    expect_equal "$RAW_STDERR" "$FIRST_STDERR"

    # Second TIDY run
    capture_output SECOND_STDOUT SECOND_STDERR $ccache_tidy_cpp test_tidy.cpp
    expect_stat preprocessed_cache_hit 1
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$SECOND_STDOUT"
    expect_equal "$RAW_STDERR" "$SECOND_STDERR"
}

SUITE_tidy_PROBE() {
    tidy_PROBE
}

SUITE_tidy_SETUP() {
    tidy_SETUP
}

SUITE_tidy() {
    tidy_tests
}
