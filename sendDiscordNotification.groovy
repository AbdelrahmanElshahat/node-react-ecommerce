#!/usr/bin/env groovy

def call(Map config) {
    def webhook = config.webhook
    def status = config.status
    def title = config.title
    def description = config.description
    def color = config.color
    def buildNumber = config.buildNumber
    def jobName = config.jobName
    def buildUrl = config.buildUrl
    def duration = config.duration

    def timestamp = new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'")
    
    def payload = [
        embeds: [
            [
                title: title,
                description: description,
                color: color,
                timestamp: timestamp,
                fields: [
                    [
                        name: "Job Name",
                        value: jobName,
                        inline: true
                    ],
                    [
                        name: "Build Number",
                        value: "#${buildNumber}",
                        inline: true
                    ],
                    [
                        name: "Status",
                        value: status,
                        inline: true
                    ],
                    [
                        name: "Duration",
                        value: duration,
                        inline: true
                    ],
                    [
                        name: "Build URL",
                        value: "[View Build](${buildUrl})",
                        inline: false
                    ]
                ],
                footer: [
                    text: "Jenkins CI/CD Pipeline",
                    icon_url: "https://wiki.jenkins.io/download/attachments/2916393/logo.png"
                ]
            ]
        ]
    ]
    
    def payloadJson = groovy.json.JsonBuilder(payload).toString()
    
    try {
        sh """
            curl -H "Content-Type: application/json" \\
                 -X POST \\
                 -d '${payloadJson}' \\
                 "${webhook}"
        """
        echo "Discord notification sent successfully"
    } catch (Exception e) {
        echo "Failed to send Discord notification: ${e.getMessage()}"
    }
}
