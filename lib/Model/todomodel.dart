
class TodoModel {

  int? _id;
  String? _title;
  String? _description;
  String? _date;
  String? _userId;
  String? _image;

  TodoModel(this._title, this._date, this._description,this._userId,this._image);

  TodoModel.withId(this._id, this._title, this._date, this._description,this._userId,this._image);

  int get id => _id!;

  String get title => _title!;

  String get description => _description!;

  String get date => _date!;

  String get userId => _userId!;

  String get image => _image!;


  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }
  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set image(String newImage) {
    this._image = newImage;
  }



  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();
      map['id'] = _id;

    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    map['userId']= _userId;
    map['image']= _image;
    return map;
  }


  TodoModel.from(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._date = map['date'];
    this._userId=map['userId'];
    this._image=map['image'];
  }
}








