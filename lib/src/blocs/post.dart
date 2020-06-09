import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ch_app/src/models/post.dart';
import 'package:ch_app/src/data/repositories.dart';

// EVENTS
abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchPostsEvent extends PostEvent {}


// STATES
abstract class PostState extends Equatable {
  @override
  List<Object> get props => [];
}

class PostEmpty extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<ConcisePost> posts;

  PostLoaded({@required this.posts}) : assert(posts != null);

  @override
  List<Object> get props => super.props
    ..addAll([
      [posts]
    ]);
}

class PostError extends PostState {}

//BLOCS
class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({@required this.postRepository}) : assert(postRepository != null);

  @override
  PostState get initialState => PostEmpty();

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    yield PostLoading();

    if (event is FetchPostsEvent) {
      final List<ConcisePost> posts = await postRepository.getPosts(20, 0);
      yield PostLoaded(posts: posts);
    }
  }
}
