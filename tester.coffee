# requires
# _ = underscore.js

Tester = (questions, onStatsUpdate) ->
  ###
  questions format by example:
  [
    {
      question: "Has anyone really been far even as decided to use even go want to do look more like?"
      answers: [
         ["Yes", false]
         ["No", false]
         ["I dunno", true]
         ["Wat", true]
      ]
    },
    ...
  ]
  ###
  remaining = []

  # correct answer to last question outputted by next()
  currentCorrectAnswers = null

  stats = {}
  emitStats = -> onStatsUpdate _.clone stats

  (init = ->
    remaining = _.shuffle questions
    stats.remaining = remaining.length
    stats.correct = 0
    stats.wrong = 0
    emitStats()
  )()

  # Public API:
  next: ->
    ###
    Returns random question from remaining questions in the following format:
    {
      question: 'The question'
      answers: [
        [ 1, 'First answer' ]
        [ 2, 'Second answer']
        ...
      ]
    }
    The answers are in random order.

    If there are no more remaining questions, the Tester starts over.
    ###
    if remaining.length is 0
      init()

    {question, answers} = remaining.pop()
    shuffledAnswers = _.shuffle answers

    currentCorrectAnswers = []
    outputAnswers = []

    for [answer, correct], index in shuffledAnswers
      choice = index + 1
      if correct
        currentCorrectAnswers.push choice
      outputAnswers.push [choice, answer]

    question: question
    answers: outputAnswers

  answer: (input) ->
    ###
    Takes an answer to the question last outputted by next()
    It can be either a single number or an array of numbers if there
    are multiple answers. The order of the answers doesn't matter.
    ###
    correct = _.isEqual currentCorrectAnswers, _.flatten([input]).map(Number).sort()
    stats.correct += correct * 1
    stats.wrong += 1 - correct * 1
    stats.remaining -= 1
    emitStats()
    [correct, currentCorrectAnswers]


convertDokuWiki = (text) ->
  ###
  Converts following dokuwiki-syntax question format to Tester-questions format:

  1. Has anyone really been far even as decided to use even go want to do look more like?
    * Incorrect answer
    * **Correct answer (bold)**
    * Another incorrect answer

  ###

  questionRe = /^\s*\d+\. (.*)$/
  answerRe = /^\s*\* (.*)$/
  correctAnswerRe = /\s*\*\*([^*]+)\*\*/

  results = []

  currentQuestion = null
  answers = []

  addCurrentQuestion = ->
    results.push
      question: currentQuestion
      answers: answers
    answers = []

  for line in text.split '\n'
    question = questionRe.exec(line)?[1]
    if question and currentQuestion
      addCurrentQuestion()
    if question
      currentQuestion = question

    answer = answerRe.exec(line)?[1]
    if answer
      correctAnswer = correctAnswerRe.exec(answer)?[1]
      answers.push if correctAnswer
        [correctAnswer, true]
      else
        [answer, false]

  addCurrentQuestion()

  return results


window.Tester = Tester

window.DokuWikiTester = (text, args...) -> Tester convertDokuWiki(text), args...
