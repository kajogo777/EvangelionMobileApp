import 'package:ch_app/src/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ch_app/src/blocs/post.dart';

class PostsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postBloc = BlocProvider.of<PostBloc>(context);

    return Stack(children: <Widget>[
      Image.asset(
        "assets/imprisoned.jpg",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "POSTS",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
            child: BlocBuilder<PostBloc, PostState>(builder: (context, state) {
          if (state is PostEmpty) {
            postBloc.add(FetchPostsEvent());
            return SizedBox.shrink();
          } else if (state is PostLoading) {
            return CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor);
          } else if (state is PostError) {
            return Text("Something Wrong Happened");
          } else if (state is PostLoaded) {
            return _buildPostList(context, state.posts, postBloc);
          }
          return null;
        })),
      )
    ]);
  }
}

Widget _buildPostList(context, List<ConcisePost> posts, postBloc) {
  if (posts.length == 0) {
    return Text.rich(
        TextSpan(
          text: "No Posts Available",
        ),
        textAlign: TextAlign.center);
  }
  return ListView.builder(
    padding: const EdgeInsets.all(5.0),
    itemCount: posts.length,
    itemBuilder: (context, index) {
      if (index < posts.length) {
        return _buildPostCard(context, posts[index], postBloc);
      } else {
        return null;
      }
    },
  );
}

Widget _buildPostCard(context, ConcisePost post, postBloc) {
  return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/post", arguments: post);
      },
      child: Card(
          elevation: 3,
          child: Container(
              padding: EdgeInsets.all(10.0),
              child: ListTile(
                isThreeLine: true,
                title: Text.rich(
                  TextSpan(text: post.title),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  textDirection: TextDirection.rtl,
                ),
                subtitle: Text.rich(TextSpan(text: post.getSummaryWithDate()),
                    style: TextStyle(fontSize: 15.0),
                    textDirection: TextDirection.rtl),
              ))));
}
