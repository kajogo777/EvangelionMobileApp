class User {
  final int id;
  final int group;
  final String name;
  final String gender;
  final DateTime dateOfBirth;

  User({
    this.id,
    this.group,
    this.name,
    this.gender,
    this.dateOfBirth,
  });

  User.fromJson(Map<String, dynamic> data):
    id = data['id'],
    group = data['group'],
    name = data['name'],
    gender = data['gender'],
    dateOfBirth = DateTime.parse(data['date_of_birth']);
}

// {
//     "id": 29,
//     "name": "lilian",
//     "group": 1,
//     "gender": "Female",
//     "date_of_birth": "2019-07-09"
// }