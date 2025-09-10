codegen:
	fvm dart run build_runner build --delete-conflicting-outputs
	fvm dart run intl_utils:generate

full_coverage:
	fvm dart run full_coverage
	bash ../scripts/ignore_generated_files_from_coverage.sh
	fvm flutter test --coverage

gen_coverage:
	fvm dart run full_coverage
	bash ../scripts/ignore_generated_files_from_coverage.sh
	fvm flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html
