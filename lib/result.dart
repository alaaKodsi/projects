class Result {
  final int status;
  final double value;
  final String? username;
  SignatureStatus signatureStatus = SignatureStatus.not_defined;

  Result(this.status, this.value, this.username);

  factory Result.fromJson(Map<String,dynamic> json) {
    final val = double.tryParse(json['value'] ?? '0.0') ?? 0.0;
    final res = Result(json['status'] ?? 500, val, json['username'],);
    final imageres = json['filename'];
    if (res.value >= 0.6)
      res.signatureStatus = SignatureStatus.verified;
    else
      res.signatureStatus = SignatureStatus.unverified;
    return res;
  }
}

enum SignatureStatus {
  verified,
  unverified,
  not_defined,
}

// {
//   'status': 200,
//   'value': 0.7,
//   'username': 'Alaa'
// };