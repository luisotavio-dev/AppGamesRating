import 'package:app_games_rating/app/app_store.dart';
import 'package:app_games_rating/app/modules/feed/model/feed_details_model.dart';
import 'package:app_games_rating/app/modules/feed/page/feed_store.dart';
import 'package:app_games_rating/app/modules/shared/widgets/card_avaliacao_widget.dart';
import 'package:app_games_rating/app/modules/shared/widgets/drawer.dart';
import 'package:app_games_rating/app/modules/shared/widgets/shadow_widget.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final appController = Modular.get<AppStore>();
  final feedController = Modular.get<FeedStore>();

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Image.asset(
          "assets/images/logo.png",
          width: 220,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: myDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Modular.to.pushNamed('/feed/register'),
        icon: Icon(Icons.thumb_up),
        label: Text("Avaliar"),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                _cardUsuario(),
                SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      "Avaliações Recentes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Divider(),
                    ),
                    FutureBuilder(
                      future: feedController.getFeed(appController.usuarioLogado.accessToken, appController.usuarioLogado.id, false),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          var error = snapshot.error;

                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            barrierDismissible: false,
                            title: "Ops!",
                            text: error,
                            onConfirmBtnTap: () {
                              Modular.to.pushReplacementNamed('/');
                            },
                          );
                        }

                        if (feedController.feed.length > 0) {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: feedController.feed.length,
                            itemBuilder: (context, index) {
                              bool liked = false;
                              bool disliked = false;

                              // verifica se essa postagem está curtida ou descurtida
                              for (var i = 0; i < feedController.likedDislikedPosts.length; i++) {
                                if (feedController.feed[index].idEvaluation == feedController.likedDislikedPosts[i].idEvaluation) {
                                  if (feedController.likedDislikedPosts[i].likeDit == 1) {
                                    liked = true;
                                    i = feedController.likedDislikedPosts.length;
                                  } else if (feedController.likedDislikedPosts[i].likeDit == 2) {
                                    disliked = true;
                                    i = feedController.likedDislikedPosts.length;
                                  }
                                }
                              }

                              FeedDetails details = FeedDetails();
                              details.feed = feedController.feed[index];
                              details.curtido = liked;
                              details.descurtido = disliked;

                              return CardAvaliacaoWidget(
                                details,
                                () {
                                  setState(() {});
                                },
                                exibirUsuario: true,
                                exibirLikes: true,
                              );
                            },
                          );
                        } else {
                          return Container(
                            child: Center(
                              child: Text("Nenhuma avaliação encontrada."),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardUsuario() {
    return GestureDetector(
      onTap: () => Modular.to.pushNamed('/profile'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF879B), Color(0xFFFF5656)],
          ),
          boxShadow: <BoxShadow>[shadow()],
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(appController.usuarioLogado.urlImage),
                    backgroundColor: Colors.transparent,
                    radius: 22,
                  ),
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        appController.usuarioLogado.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      appController.usuarioLogado.nickName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      feedController.quantidadePostsUsuario == 0
                          ? "Nenhuma publicação"
                          : feedController.quantidadePostsUsuario > 1
                              ? feedController.quantidadePostsUsuario.toString() + ' publicações'
                              : '1 publicação',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              size: 35,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
