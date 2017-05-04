# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

moment = require 'moment' # 日付をパースするライブラリ

module.exports = (robot) ->

  # 現在のレコード数
  length = robot.brain.get('records.length') >> 0

  robot.hear /(\d+).*(add|ふえた)\D*([\d\:\/\s]+)?/i, (res) ->
    # e.g. res.match[1] == '1234'
    amount = parseInt res.match[1]
    # e.g. res.match[3] == '4/1 10:00'
    datetime = parseDatetime res.match[3]
    robot.brain.set "records.#{length}", "#{amount}\tadd\t#{datetime}"
    robot.brain.set "records.length", ++length
    res.send "すごーい！お金がふえたよ +#{amount}円"

  robot.hear /(\d+).*(sub|へった)\D*([\d\:\/\s]+)?/i, (res) ->
    # e.g. res.match[1] == '1234'
    amount = parseInt res.match[1]
    # e.g. res.match[3] == '15:00'
    datetime = parseDatetime res.match[3]
    robot.brain.set "records.#{length}", "#{amount}\tsub\t#{datetime}"
    robot.brain.set "records.length", ++length
    res.send "ざんねん！お金がへったよ -#{amount}円"

  robot.hear /back|もどす/, (res) ->
    if length > 0
      robot.brain.set "records.length", --length
      res.send "もどしたよ！" + robot.brain.get "records.#{length}"
    else
      res.send "えっ？"

  robot.hear /history|りれき/i, (res) ->
    if length > 0
      records = [0..length - 1].map (i) -> robot.brain.get "records.#{i}"
      res.send "けんすう: #{length}件\n" + records.join('\n')
    else
      res.send "は？"

  robot.hear /how much|いくら/i, (res) ->
    if length > 0
      records = [0..length - 1].map (i) -> robot.brain.get "records.#{i}"
      money = 0
      for record in records
        # e.g. record == '1234 add'
        matches = /(\d+)\s(add|sub)/i.exec record
        if matches[2] == 'add' then money += parseInt matches[1]
        if matches[2] == 'sub' then money -= parseInt matches[1]
      res.send "#{money}円"
    else
      res.send "0円"

parseDatetime = (string) ->
  # 日付文字列をパース
  datetime =
    if /^\d{2,4}\/\d\d?\/\d\d? \d\d?\:\d\d?/.test string
      moment string, 'YYYY/MM/DD HH:mm:ss' # e.g. string == '2017/5/4 11:53'
    else if /^\d\d?\/\d\d? \d\d?\:\d\d?/.test string
      moment string, 'MM/DD HH:mm:ss' # e.g. string == '5/4 11:53'
    else if /^\d\d?\/\d\d?/.test string
      moment string, 'MM/DD' # e.g. string == '5/4'
    else if /^\d\d?\:\d\d?/.test string
      moment string, 'HH:mm:ss' # e.g. string == '11:53'
    else
      moment()

  # YYYY/MM/DD HH:mm:ss に再フォーマット
  datetime.format 'YYYY/MM/DD HH:mm:ss'
