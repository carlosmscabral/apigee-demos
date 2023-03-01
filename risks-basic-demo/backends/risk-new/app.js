const express = require('express')

const app = express()

const port = process.env.PORT || 8080

app.use(express.json())

app.post('/score', (req, res) => {
    const input = req.body
    const risk = Math.floor(Math.random() * 100)

    res.send({input, risk, source: "new-service"})

})

app.get('/status', (req, res) => {
    // delay between 1 and 4 seconds.
    const delay = (Math.random() * (1000)) + 1000
    setTimeout(() => {
        res.set('Content-Type', 'text/plain')
        res.send("Ok")
    }, delay)
})

app.listen(port, () => {
    console.log('Server is up on port ' + port)
})