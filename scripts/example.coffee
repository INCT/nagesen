# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  # 現在のレコード数
  length = robot.brain.get('records.length') >> 0

  robot.hear /(\d+).*(add|\ふえた)/i, (res) ->
    # e.g. res.match[1] === '1234'
    amount = parseInt res.match[1]
    robot.brain.set "records.#{length}", "#{amount}\tadd"
    robot.brain.set "records.length", ++length
    res.send "すごーい！お金がふえたよ +#{amount}円"

  robot.hear /(\d+).*(sub|\へった)/i, (res) ->
    # e.g. res.match[1] === '1234'
    amount = parseInt res.match[1]
    robot.brain.set "records.#{length}", "#{amount}\tsub"
    robot.brain.set "records.length", ++length
    res.send "ざんねん！お金がへったよ -#{amount}円"

  robot.hear /back|\もどす/, (res) ->
    if length > 0
      robot.brain.set "records.length", --length
      res.send "もどしたよ！" + robot.brain.get "records.#{length}"
    else
      res.send "えっ？"

  robot.hear /history|\りれき/i, (res) ->
    records = [0..length - 1].map (i) -> robot.brain.get "records.#{i}"
    res.send "けんすう: #{length}件\n" + records.join('\n')

  robot.hear /how much|\いくら/i, (res) ->
    if length > 0
      records = [0..length - 1].map (i) -> robot.brain.get "records.#{i}"
      money = 0
      for record in records
        # e.g. record === '1234 add'
        matches = /(\d+)\s(add|sub)/i.exec record
        if matches[2] == 'add' then money += parseInt matches[1]
        if matches[2] == 'sub' then money -= parseInt matches[1]
      res.send "#{money}円"
    else
      res.send "0円"
