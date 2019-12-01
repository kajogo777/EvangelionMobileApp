import 'package:flutter/material.dart';

class Challenge {
  final int id;
  final String question;
  final DateTime activeDate;
  final Scripture scripture;
  final Reward reward;
  final List<Answer> answers;
  final Response response;

  Challenge(
      {this.id,
      this.question,
      this.activeDate,
      this.scripture,
      this.reward,
      this.answers,
      this.response});

  factory Challenge.fromJson(Map<String, dynamic> data) {
    final date = DateTime.parse(data['active_date']);

    return Challenge(
        id: data['id'],
        activeDate: DateTime(date.year, date.month, date.day),
        question: data['question'],
        scripture: Scripture.fromJson(data['scripture']),
        reward: Reward.fromJson(data['reward']),
        answers: (data['answers'] as List)
            .map((answer) => Answer.fromJson(answer))
            .toList(),
        response: data['response'] != null
            ? Response.fromJson(data['response'], data['id'])
            : null);
  }

  Challenge copyWith(Response response) {
    return Challenge(
        id: this.id,
        question: this.question,
        activeDate: DateTime(
            this.activeDate.year, this.activeDate.month, this.activeDate.day),
        scripture: this.scripture.copy(),
        reward: this.reward.copy(),
        answers: this.answers.map((a) => a.copy()).toList(),
        response: response ?? this.response?.copy());
  }

  bool isAnswered() {
    return this.response != null;
  }

  bool isRevealed() {
    final now = DateTime.now();
    return this.activeDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool isAnsweredCorrectly() {
    if (!this.isAnswered()) return false;
    if (!this.isRevealed()) return false;

    Answer answer = this
        .answers
        .firstWhere((answer) => answer.id == this.response.answerId);

    return answer.revealed && answer.correct;
  }

  String getActiveDateString() {
    return "${this.activeDate.year.toString()}-${this.activeDate.month.toString()}-${this.activeDate.day.toString()}";
  }
}

class Scripture {
  final int chapter;
  final Map<String, String> book;
  final Map<String, String> reference;
  final Map<String, List<String>> verseText;
  final List<int> verseIndexes;

  Scripture(
      {this.chapter,
      this.book,
      this.reference,
      this.verseText,
      this.verseIndexes});

  Scripture.fromJson(Map<String, dynamic> data)
      : chapter = data['chapter'],
        book = {'ar': data['book'], 'en': data['book_en']},
        reference = {'ar': data['reference'], 'en': data['reference_en']},
        verseText = {
          'ar': data['verse_text'].cast<String>(),
          'en': data['verse_text_en'].cast<String>()
        },
        verseIndexes = data['verse_indexes'].cast<int>();

  String getText(String lang) {
    String text = "";
    for (int i = 0; i < verseText[lang].length; i++) {
      text += i > 0 ? " " : "";
      text += "${this.verseIndexes[i]} ${this.verseText[lang][i]}";
    }
    return text;
  }

  Scripture copy() {
    return Scripture(
        chapter: this.chapter,
        book: new Map.from(this.book),
        reference: new Map.from(this.reference),
        verseText: new Map.from(this.verseText),
        verseIndexes: new List<int>.from(this.verseIndexes));
  }
}

class Reward {
  final String name;
  final Color color;

  Reward({this.name, this.color});

  factory Reward.fromJson(Map<String, dynamic> data) {
    String hexColor = data['color'].toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }

    return Reward(
        name: data['name'], color: Color(int.parse(hexColor, radix: 16)));
  }

  Reward copy() {
    return Reward(
      name: this.name,
      color: new Color(this.color.value),
    );
  }
}

class Answer {
  final int id;
  final String text;
  final bool revealed;
  final bool correct;

  Answer({this.id, this.text, this.revealed, this.correct});

  factory Answer.fromJson(Map<String, dynamic> data) {
    if (data.containsKey('correct')) {
      return Answer(
          id: data['id'],
          text: data['text'],
          revealed: true,
          correct: data['correct']);
    } else {
      return Answer(
          id: data['id'], text: data['text'], revealed: false, correct: false);
    }
  }

  Answer copy() {
    return Answer(
        id: this.id,
        text: this.text,
        revealed: this.revealed,
        correct: this.correct);
  }
}

class Response {
  final int id;
  final int answerId;
  final int challengeId;

  Response({
    this.id,
    this.answerId,
    this.challengeId,
  });

  Response.fromJson(Map<String, dynamic> data, int challengeId)
      : id = data['id'],
        answerId = data['answer'],
        challengeId = challengeId;

  Map<String, dynamic> toJson() => {
        'answer': this.answerId,
        'challenge': this.challengeId,
      };

  Response copy() {
    return Response(
      id: this.id,
      answerId: this.answerId,
      challengeId: this.challengeId,
    );
  }
}
