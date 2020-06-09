import 'package:ch_app/src/models/post.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ch_app/src/blocs/post_details.dart';

typedef Callback = Function(void);

class PostDetails extends StatefulWidget {
  // final ConcisePost post;

  PostDetails({Key key}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  num _position = 1;

  @override
  Widget build(BuildContext context) {
    final ConcisePost post = ModalRoute.of(context).settings.arguments;

    doneLoading(String A) {
      setState(() {
        _position = 0;
      });
    }

    startLoading(String A) {
      setState(() {
        _position = 1;
      });
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            post.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body:
            BlocBuilder<PostDetailsBloc, PostState>(builder: (context, state) {
          if (state is PostEmpty) {
            BlocProvider.of<PostDetailsBloc>(context)
                .add(FetchPostEvent(postId: post.id));
            return SizedBox.shrink();
          } else if (state is PostLoading) {
            return Center(
                child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor));
          } else if (state is PostError) {
            return Text("Something Wrong Happened");
          } else if (state is PostLoaded) {
            var html =
                """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>""" +
                    state.post.text +
                    """</html>""";

            var dataUri = Uri.dataFromString(html,
                    mimeType: 'text/html',
                    encoding: Encoding.getByName('utf-8'))
                .toString();
            return IndexedStack(index: _position, children: <Widget>[
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: WebView(
                  initialUrl: dataUri,
                  javascriptMode: JavascriptMode.disabled,
                  onPageFinished: doneLoading,
                  onPageStarted: startLoading,
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                )),
              ),
            ]);
          }
          return null;
        }));
  }
}
