import 'package:app_games_rating/app/app_store.dart';
import 'package:app_games_rating/app/modules/loading/page/loading_store.dart';
import 'package:app_games_rating/app/modules/login/page/login_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LoadingPage extends StatefulWidget {
  @override
  LoadingPageState createState() => LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {
  final appController = Modular.get<AppStore>();
  final loadingController = Modular.get<LoadingStore>();
  final loginController = Modular.get<LoginStore>();

  @override
  void initState() {
    loadingController.verificarUsuarioLogado().then((value) async {
      await Firebase.initializeApp();
      if (value.length > 0) {
        // busca e valida um novo token de acesso
        String newToken = await loginController.refreshToken(value[0].accessToken);
        value[0].accessToken = newToken;
        print('Token de acesso atualizado!');
        await appController.setUsuarioLogado(value[0]);
        Modular.to.pushReplacementNamed('/feed');
      } else {
        Modular.to.pushReplacementNamed('/login');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
