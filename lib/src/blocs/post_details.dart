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

class FetchPostEvent extends PostEvent {
  final int postId;

  FetchPostEvent({@required this.postId})
      : assert(postId != null);

  @override
  List<Object> get props => super.props..addAll([postId]);
}

// STATES
abstract class PostState extends Equatable {
  @override
  List<Object> get props => [];
}

class PostEmpty extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final Post post;

  PostLoaded({@required this.post}) : assert(post != null);

  @override
  List<Object> get props => super.props
    ..addAll([
      [post]
    ]);
}

class PostError extends PostState {}

//BLOCS
class PostDetailsBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostDetailsBloc({@required this.postRepository}) : assert(postRepository != null);

  @override
  PostState get initialState => PostEmpty();

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    yield PostLoading();

    if (event is FetchPostEvent) {
      final Post post = await postRepository.fetchPost(event.postId);
      yield PostLoaded(post: post);
    }
  }
}
