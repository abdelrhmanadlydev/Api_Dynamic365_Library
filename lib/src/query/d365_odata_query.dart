class D365ODataQuery {
  final List<String> _select = [];
  final List<String> _orderBy = [];
  final Map<String, String> _custom = {};

  String? _filter;
  int? _top;
  int? _skip;
  bool? _count;
  bool _crossCompany = false;
  String? _dataAreaId;

  D365ODataQuery select(List<String> fields) {
    _select
      ..clear()
      ..addAll(fields);

    return this;
  }

  D365ODataQuery filter(String value) {
    _filter = value;
    return this;
  }

  D365ODataQuery orderBy(List<String> fields) {
    _orderBy
      ..clear()
      ..addAll(fields);

    return this;
  }

  D365ODataQuery top(int value) {
    _top = value;
    return this;
  }

  D365ODataQuery skip(int value) {
    _skip = value;
    return this;
  }

  D365ODataQuery count([bool value = true]) {
    _count = value;
    return this;
  }

  D365ODataQuery crossCompany([bool value = true]) {
    _crossCompany = value;
    return this;
  }

  D365ODataQuery company(String dataAreaId) {
    _dataAreaId = dataAreaId;
    return this;
  }

  D365ODataQuery custom(String key, String value) {
    _custom[key] = value;
    return this;
  }

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};

    if (_select.isNotEmpty) {
      params[r'$select'] = _select.join(',');
    }

    final List<String> filters = [];

    if (_filter != null && _filter!.trim().isNotEmpty) {
      filters.add(_filter!.trim());
    }

    if (_dataAreaId != null && _dataAreaId!.trim().isNotEmpty) {
      filters.add("dataAreaId eq '${_escape(_dataAreaId!)}'");
    }

    if (filters.isNotEmpty) {
      params[r'$filter'] = filters.join(' and ');
    }

    if (_orderBy.isNotEmpty) {
      params[r'$orderby'] = _orderBy.join(',');
    }

    if (_top != null) {
      params[r'$top'] = _top.toString();
    }

    if (_skip != null) {
      params[r'$skip'] = _skip.toString();
    }

    if (_count != null) {
      params[r'$count'] = _count.toString();
    }

    if (_crossCompany) {
      params['cross-company'] = 'true';
    }

    params.addAll(_custom);

    return params;
  }

  String _escape(String value) {
    return value.replaceAll("'", "''");
  }
}
