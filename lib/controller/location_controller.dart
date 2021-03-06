import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mightymeteomap/utils/weather_icon_mapper.dart';
import 'package:geolocator/geolocator.dart';

// Controller GetX qui gérer la récupération d'information et les variables à afficher dans la page
class LocationController extends GetxController {
  // variable global pour les appels api
  final String _apiUrl = "http://api.openweathermap.org";
  final String _apiKey = "04861993e066f5b8aaffe6988957c264";

  // variable Getx
  final RxDouble _latitude = 0.0.obs;
  final RxDouble _longitude = 0.0.obs;
  final RxString _name = "".obs;
  final RxString _searchTown = "".obs;

  // fonction GetX pour récupérer les valeurs à afficher sur la page
  changeLatitude(value) => _latitude.value = value;
  changeLongitude(value) => _longitude.value = value;
  changeName(value) => _name.value = value;
  changeSearchTown(value) => _searchTown.value = value;

  getLatitude() => _latitude.value;
  getLongitude() => _longitude.value;
  getName() => _name.value;
  getSearchTown() => _searchTown.value;

  // variable Getx
  final List<RxDouble> _temp = List.generate(4, (index) => 0.0.obs);
  final List<RxDouble> _tempMin = List.generate(4, (index) => 0.0.obs);
  final List<RxDouble> _tempMax = List.generate(4, (index) => 0.0.obs);
  final List<RxInt> _humi = List.generate(4, (index) => 0.obs);
  final List<RxString> _icon = List.generate(4, (index) => "".obs);

  // fonction GetX pour récupérer les valeurs à afficher sur la page
  changeTemp(value, index) => _temp[index].value = value - 273.15;
  changeTempMin(value, index) => _tempMin[index].value = value - 273.15;
  changeTempMax(value, index) => _tempMax[index].value = value - 273.15;
  changeHumi(value, index) => _humi[index].value = value;
  changeIcon(value, index) => _icon[index].value = value;

  getTemp(index) =>
      double.parse(_temp[index].value.toString()).toStringAsFixed(1);
  getTempMin(index) =>
      double.parse(_tempMin[index].value.toString()).toStringAsFixed(1);
  getTempMax(index) =>
      double.parse(_tempMax[index].value.toString()).toStringAsFixed(1);
  getHumi(index) => _humi[index].value;
  getIcon(index) => _icon[index].value;

  // fonction qui es appelé à l'ouverture de la page météo
  @override
  void onInit() async {
    await _determinePosition();
    searchByLocation();
    super.onInit();
  }

  // fonction qui récupére la météo du jour et prévisions météo selon ces données GPS
  void searchByLocation() async {
    await getWeatherDataFromLocation();
    await getForecastFromLocation();
  }

  // fonction qui récupére la météo du jour et prévisions météo selon le nom d'une ville
  void searchFromCity(String cityName) async {
    await getWeatherDataFromCity(cityName);
    await getForecastFromCity(cityName);
  }

  // récupération des prévisions météo selon des données GPS sur 3 jours
  Future<void> getForecastFromLocation() async {
    final url =
        '$_apiUrl/data/2.5/forecast/?lat=$_latitude&lon=$_longitude&appid=$_apiKey&cnt=25';
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      for (int i = 1; i < 4; i += 1) {
        changeTemp(res['list'][8 * i]['main']['temp'], i);
        changeTempMin(res['list'][8 * i]['main']['temp_min'], i);
        changeTempMax(res['list'][8 * i]['main']['temp_max'], i);
        changeHumi(res['list'][8 * i]['main']['humidity'], i);
        changeIcon(res['list'][8 * i]['weather'][0]['icon'], i);
      }
    } else {
      // error
      changeName("Erreur");
      for (int i = 1; i < 4; i += 1) {
        changeTemp(0, i);
        changeTempMin(0, i);
        changeTempMax(0, i);
        changeHumi(0, i);
        changeIcon("01d", i);
      }
    }
  }

  // récupération des prévisions météo selon le nom d'une ville sur 3 jours
  Future<void> getForecastFromCity(String cityName) async {
    final url = '$_apiUrl/data/2.5/forecast/?q=$cityName&appid=$_apiKey&cnt=25';
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      for (int i = 1; i < 4; i += 1) {
        changeTemp(res['list'][8 * i]['main']['temp'], i);
        changeTempMin(res['list'][8 * i]['main']['temp_min'], i);
        changeTempMax(res['list'][8 * i]['main']['temp_max'], i);
        changeHumi(res['list'][8 * i]['main']['humidity'], i);
        changeIcon(res['list'][8 * i]['weather'][0]['icon'], i);
      }
    } else {
      // error
      changeName("Erreur");
      for (int i = 1; i < 4; i += 1) {
        changeTemp(0, i);
        changeTempMin(0, i);
        changeTempMax(0, i);
        changeHumi(0, i);
        changeIcon("01d", i);
      }
    }
  }

  // récupération de la météo du jour selon le nom d'une ville
  Future<void> getWeatherDataFromCity(String cityName) async {
    final url = '$_apiUrl/data/2.5/weather?q=$cityName&appid=$_apiKey';
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      changeTemp(res['main']['temp'], 0);
      changeTempMin(res['main']['temp_min'], 0);
      changeTempMax(res['main']['temp_max'], 0);
      changeHumi(res['main']['humidity'], 0);
      changeIcon(res['weather'][0]['icon'], 0);
      changeName(cityName);
    } else {
      // error
      changeName("Erreur");
      changeTemp(0, 0);
      changeTempMin(0, 0);
      changeTempMax(0, 0);
      changeHumi(0, 0);
      changeIcon("01d", 0);
    }
  }

  // récupération de la météo du jour selon des données GPS
  Future<void> getWeatherDataFromLocation() async {
    final url =
        '$_apiUrl/data/2.5/weather?lat=$_latitude&lon=$_longitude&appid=$_apiKey';
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      changeTemp(res['main']['temp'], 0);
      changeTempMin(res['main']['temp_min'], 0);
      changeTempMax(res['main']['temp_max'], 0);
      changeHumi(res['main']['humidity'], 0);
      changeIcon(res['weather'][0]['icon'], 0);
      changeName(res['name']);
    } else {
      // error
      changeName("Erreur");
      changeTemp(0, 0);
      changeTempMin(0, 0);
      changeTempMax(0, 0);
      changeHumi(0, 0);
      changeIcon("01d", 0);
    }
  }

  // fonction qui permet de recupérer l'icone contenue dans une font selon un id
  IconData getIconData(index) {
    switch (_icon[index].value) {
      case '01d':
        return WeatherIcons.clearDay;
      case '01n':
        return WeatherIcons.clearNight;
      case '02d':
        return WeatherIcons.fewCloudsDay;
      case '02n':
        return WeatherIcons.fewCloudsNight;
      case '03d':
      case '04d':
        return WeatherIcons.cloudsDay;
      case '03n':
      case '04n':
        return WeatherIcons.cloudsNight;
      case '09d':
        return WeatherIcons.showerRainDay;
      case '09n':
        return WeatherIcons.showerRainNight;
      case '10d':
        return WeatherIcons.rainDay;
      case '10n':
        return WeatherIcons.rainNight;
      case '11d':
        return WeatherIcons.thunderStormDay;
      case '11n':
        return WeatherIcons.thunderStormNight;
      case '13d':
        return WeatherIcons.snowDay;
      case '13n':
        return WeatherIcons.snowNight;
      case '50d':
        return WeatherIcons.mistDay;
      case '50n':
        return WeatherIcons.mistNight;
      default:
        return WeatherIcons.clearDay;
    }
  }

  // fonction qui permet d'avoir la position GPS de l'utilisateur (longitude et latitude)
  // popup qui demande l'autorisation de l'utilisateur d'accéder à sa position GPS
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    changeLatitude(position.latitude.toDouble());
    changeLongitude(position.longitude.toDouble());
  }
}
