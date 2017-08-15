ELASTICSEARCH_ROOT = "http://archive.xmen:9200"

getTodayDate = () ->
  today = new Date()
  dd = today.getDate()
  mm = today.getMonth() + 1
  yyyy = today.getFullYear()

  ('0' + dd).slice(-2) + '-' + ('0' + mm).slice(-2) + '-' + yyyy

module.exports = (robot) ->
  robot.hear /.*/i, (res) ->
    data = {
      text: res.message.text,
      name: res.message.user.name,
      real_name: res.message.user.real_name,
      room: res.message.room,
      timestamp: Date.now()
    }
    robot.http("#{ELASTICSEARCH_ROOT}/archive-#{getTodayDate()}/#{res.message.room}/#{res.message.id}")
    .put(JSON.stringify(data)) (err, response, body) ->
      if err
        console.log(err)

  robot.respond /(search|find) (.*)/i, (res) ->
    query = JSON.stringify({
      "query": {
        "bool": {
          "must": [
            { "match_phrase": { "text": res.match[2] } },
            { "match": { "room": res.message.room } }
          ]
        }
      }
    })

    robot.http("#{ELASTICSEARCH_ROOT}/_all/_search")
    .get(query) (err, response, body) ->
      if err
        res.send("Error performing search.")
        console.log(err)
      else
        hits = JSON.parse(body).hits.hits.map((hit) => hit._source.text)
        res.send(hits.join('\n\n'))
