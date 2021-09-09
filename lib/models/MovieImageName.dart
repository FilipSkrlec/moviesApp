class MovieImageName {
  String id = "";
  String name = "";
  String backdropPath = "";

  MovieImageName(id, name, backdropPath) {
    this.id = id;
    this.name = name;
    this.backdropPath = backdropPath;
  }

  String getId() {
    return this.id;
  }

  String getName() {
    return this.name;
  }

  String getBackdropPath() {
    return this.backdropPath;
  }
}
