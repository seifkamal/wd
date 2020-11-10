#!/usr/bin/env bash
tash::setup() {
  test_dir="${PWD}/testdir"
  test_dir_one="${test_dir}/one"
  test_dir_two="${test_dir_one}/two"
  test_dir_three="${test_dir_two}/three"
  mkdir -p "${test_dir_three}"

  WD_PINS="${test_dir}/test_pins.txt"
  # shellcheck source=wd.sh
  source wd.sh
}

tash::setup_each() {
  # shellcheck disable=SC2164  
  cd "${test_dir}"
}

tash::teardown_each() {
  [[ ! -f "${WD_PINS}" ]] || rm "${WD_PINS}"
}

tash::teardown() {
  rm -rf "${test_dir}"
}

assert::dir() {
  local -r exp_dir="${1:?'assert::dir missing expected PWD arg'}"
  [[ "${PWD}" == "${exp_dir}" ]] || {
    echo "Expected to be in '${exp_dir}', got '${PWD}'"
    return 1
  }
}

test::cd() {
  wd "${test_dir_two}" >/dev/null || echo "Failed to cd to dir 'two'"
  assert::dir "${test_dir_two}"

  wd .. >/dev/null || echo "Failed to cd upwards (\`..\`)"
  assert::dir "${test_dir_one}"

  wd - >/dev/null || echo "Failed to cd backwards (\`-\`)"
  assert::dir "${test_dir_two}"

  wd >/dev/null || echo 'Failed to cd home'
  assert::dir "${HOME}"

  ! wd invalid 2>/dev/null || echo 'Expected invalid dir arg to fail'
  assert::dir "${HOME}"
}

test::create() {
  wd --create new new >/dev/null || {
    echo "Failed to create 'new' dir"
    return 1
  }
  assert::dir "${test_dir}/new"

  wd --create new2 >/dev/null || echo "Failed to create 'new2' dir"
  assert::dir "${test_dir}/new/new2"

  wd new >/dev/null || echo "Failed to cd to pin 'new'"
  assert::dir "${test_dir}/new"
}

test::pin() {
  {
    wd --pin . main \
      && wd --pin one \
      && wd --pin one/two/three last
  } >/dev/null || {
    echo 'Pin commands failed'
    return 1
  }

  wd one >/dev/null || echo "Failed to cd to pin 'one'"
  assert::dir "${test_dir_one}"

  wd last >/dev/null || echo "Failed to cd to pin 'last'"
  assert::dir "${test_dir_three}"

  wd main >/dev/null || echo "Failed to cd to pin 'main'"
  assert::dir "${test_dir}"

  wd --unpin last >/dev/null || {
    echo "Failed to unpin 'last'"
    return 1
  }

  ! wd last 2>/dev/null || echo 'Expected invalid pin arg to fail'
  assert::dir "${test_dir}"

  local res_list; res_list="$(wd --list)" || {
    echo 'Failed to list pins'
    return 1
  }

  IFS=$'\n' read -d '' -ra res_pins <<< "${res_list}"
  local -r exp_pin_count=2 act_pin_count="${#res_pins[@]}"
  [[ ${act_pin_count} -eq "${exp_pin_count}" ]] \
    || echo "Expected ${exp_pin_count} pins in list, got ${act_pin_count}"
}
