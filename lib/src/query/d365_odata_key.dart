class D365ODataKey {
  final Map<String, Object?> values;

  const D365ODataKey(this.values);

  String toODataKey() {
    final List<String> parts = [];

    values.forEach((String key, Object? value) {
      parts.add('$key=${_formatValue(value)}');
    });

    return parts.join(',');
  }

  String _formatValue(Object? value) {
    if (value == null) {
      return 'null';
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    final String escaped = value.toString().replaceAll("'", "''");

    return "'$escaped'";
  }
}
