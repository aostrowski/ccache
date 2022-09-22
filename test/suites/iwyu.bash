iwyu_PROBE() {
    if [ -z "$REAL_IWYU" ]; then
        echo "iwyu is not available"
    fi
}

iwyu_SETUP() {
    cat <<EOF > test_iwyu_positive.cpp
int main() {}
EOF

    cat <<EOF > test_iwyu_negative.cpp
#include <iostream>

int main() {}
EOF

    cat <<EOF > test_iwyu_compilation_error.cpp
int main() {
  whoops
}
EOF

}

iwyu_tests() {
    iwyu_opts_cpp=""
    ccache_iwyu_cpp="$CCACHE $REAL_IWYU $iwyu_opts_cpp"

    # -------------------------------------------------------------------------
    TEST "Positive case - no suggestions"

    # Run IWYU without CCache
    capture_output RAW_STDOUT RAW_STDERR $REAL_IWYU $iwyu_opts_cpp test_iwyu_positive.cpp
    expect_equal "" "$RAW_STDOUT"

    # First IWYU run
    capture_output FIRST_STDOUT FIRST_STDERR $ccache_iwyu_cpp test_iwyu_positive.cpp
    expect_stat preprocessed_cache_hit 0
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$FIRST_STDOUT"
    expect_equal "$RAW_STDERR" "$FIRST_STDERR"

    # Second IWYU run
    capture_output SECOND_STDOUT SECOND_STDERR $ccache_iwyu_cpp test_iwyu_positive.cpp
    expect_stat preprocessed_cache_hit 1
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$SECOND_STDOUT"
    expect_equal "$RAW_STDERR" "$SECOND_STDERR"

    # -------------------------------------------------------------------------
    TEST "Negative case - superfluous header"

    # Run IWYU without CCache
    capture_output RAW_STDOUT RAW_STDERR $REAL_IWYU $iwyu_opts_cpp test_iwyu_negative.cpp
    expect_equal "" "$RAW_STDOUT"

    # First IWYU run
    capture_output FIRST_STDOUT FIRST_STDERR $ccache_iwyu_cpp test_iwyu_negative.cpp
    expect_stat preprocessed_cache_hit 0
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$FIRST_STDOUT"
    expect_equal "$RAW_STDERR" "$FIRST_STDERR"

    # Second IWYU run
    capture_output SECOND_STDOUT SECOND_STDERR $ccache_iwyu_cpp test_iwyu_negative.cpp
    expect_stat preprocessed_cache_hit 1
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$SECOND_STDOUT"
    expect_equal "$RAW_STDERR" "$SECOND_STDERR"

    # -------------------------------------------------------------------------
    TEST "Compilation error"

    # Run IWYU without CCache
    capture_output RAW_STDOUT RAW_STDERR $REAL_IWYU $iwyu_opts_cpp test_iwyu_compilation_error.cpp
    expect_equal "" "$RAW_STDOUT"

    # First IWYU run
    capture_output FIRST_STDOUT FIRST_STDERR $ccache_iwyu_cpp test_iwyu_compilation_error.cpp
    expect_stat preprocessed_cache_hit 0
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$FIRST_STDOUT"
    expect_equal "$RAW_STDERR" "$FIRST_STDERR"

    # Second IWYU run
    capture_output SECOND_STDOUT SECOND_STDERR $ccache_iwyu_cpp test_iwyu_compilation_error.cpp
    expect_stat preprocessed_cache_hit 1
    expect_stat cache_miss 1
    expect_stat files_in_cache 1
    expect_equal "" "$SECOND_STDOUT"
    expect_equal "$RAW_STDERR" "$SECOND_STDERR"
}

SUITE_iwyu_PROBE() {
    iwyu_PROBE
}

SUITE_iwyu_SETUP() {
    iwyu_SETUP
}

SUITE_iwyu() {
    iwyu_tests
}
