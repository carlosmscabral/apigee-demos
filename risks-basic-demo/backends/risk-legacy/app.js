const express = require('express')

const app = express()

const port = process.env.PORT || 8080

app.use(express.json())

app.post('/score', (req, res) => {
    // delay between 1 and 4 seconds.
    const delay = (Math.random() * (1000)) + 1000
    const input = req.body
    const risk = Math.floor(Math.random() * 100)

    setTimeout(() => {
        res.send({input: {name: input.name, cpf: input.cpf}, risk, source: "legacy-service"})
    }, delay)
})

app.get('/status', (req, res) => {
    // delay between 1 and 4 seconds.
    const delay = (Math.random() * (1000)) + 1000
    setTimeout(() => {
        res.set('Content-Type', 'application/xml')
        data = `<?xml version="1.0" encoding="UTF-8"?>`
        data+=`<status>Ok</status>`
        res.send(data)
    }, delay)
})

app.listen(port, () => {
    console.log('Server is up on port ' + port)
})