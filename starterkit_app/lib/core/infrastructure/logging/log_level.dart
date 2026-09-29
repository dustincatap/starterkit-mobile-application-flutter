enum LogLevel {
  off(0),
  debug(100),
  info(200),
  warning(300),
  error(400);

  const LogLevel(this.value);

  final int value;
}
