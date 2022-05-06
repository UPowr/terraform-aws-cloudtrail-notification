var AWS = require('aws-sdk')
var cwl = new AWS.CloudWatchLogs();
var cw = new AWS.CloudWatch();
var sns = new AWS.SNS({ apiVersion: '2010-03-31' });

exports.handler = function (event, context) {
    processEvent(event, context);
};

var handleCloudWatch = function (data, alarm, events) {
    sendEmail(generateEmailContent(data, alarm, events))
}

var processEvent = function (event, context) {
    var alarmName = event.detail.alarmName;
    var time = event.time;
    var messageNotification = null
    console.log(event)
    getWatchlogData(alarmName, time, function (err, data, alarm) {
        clouldTrail = JSON.parse(data.events[0].message);
        messageNotification = handleCloudWatch(clouldTrail, alarm, data.events)

    })
}

function getWatchlogData(alarmName, time, fn) {
    getAlarm(alarmName, function (err, data) {
        if (err) { console.log(err, err.stack) } // an error occurred
        else {
            const alarms = data.MetricAlarms[0]
            getMetricsFilter(data.MetricAlarms[0].MetricName, data.MetricAlarms[0].Namespace, function (err, data) {
                if (err) console.log('Error is:', err);
                else {
                    if (data.metricFilters[0].logGroupName == process.env.LOG_GROUP) {
                        getFilterLogEvents(data.metricFilters[0].logGroupName, data.metricFilters[0].filterPattern, time, function (err, data) {
                            if (err) console.log('Error is:', err);
                            else {
                                fn(err, data, alarms)
                            }
                        })
                    } else {
                        console.info(`Event:${data.eventName} not found`)
                    }
                }
            })
        }
    })
}

function getAlarm(alarm_name, fn) {
    var params = {
        AlarmNames: [
            alarm_name
        ]
    };
    cw.describeAlarms(params, fn);
}

function getMetricsFilter(metricName, metricNamespace, fn) {
    var requestParams = {
        metricName: metricName,
        metricNamespace: metricNamespace
    };
    cwl.describeMetricFilters(requestParams, fn);
}

function getFilterLogEvents(logGroupName, filterPattern, time, fn) {
    var startTime = new Date(time);
    var endTime = new Date(time);
    startTime.setSeconds(startTime.getSeconds() - process.env.OFFSET);
    var parameters = {
        'logGroupName': logGroupName,
        'filterPattern': filterPattern,
        'startTime': startTime.getTime(),
        'endTime': endTime.getTime()
    };
    cwl.filterLogEvents(parameters, fn);
}

var sendEmail = function (structureMessage, callback) {
    var params = {
        Message: structureMessage.message, /* required */
        TopicArn: process.env.TOPIC_ARN,
        Subject: structureMessage.subject,
        MessageStructure: 'string'
    };
    console.log("===SENDING EMAIL===");
    var email = sns.publish(params).promise().then(function (data) {
        console.log(`Message ${params.Message} sent to the topic ${params.TopicArn}`);
        console.log("MessageID is " + data.MessageId);
    }).catch(function (err) {
        console.error(err, err.stack);
    });
}

function generateEmailContent(clouldTrail, alarm, events) {
    var date = new Date(clouldTrail.eventTime);
    console.log(`processing ${clouldTrail.eventName} notification`)

    customMessage = `You are receiving this email because your Amazon CloudWatch Alarm "${alarm.AlarmName}" in the ${clouldTrail.awsRegion} region has entered the ${alarm.StateValue} state, because ${alarm.StateReason}  at ${alarm.StateUpdatedTimestamp}
    
    View this alarm in the AWS Management Console:
    https://${clouldTrail.awsRegion}.console.aws.amazon.com/cloudwatch/home?region=${clouldTrail.awsRegion}#s=Alarms&alarm=${encodeURI(alarm.AlarmName)}
    
    Alarm Details:
    - Name: ${alarm.AlarmName}
    - Description: ${alarm.AlarmDescription}
    - AWS Account: ${clouldTrail.userIdentity.accountId}
    - Alarm Arn: ${alarm.AlarmArn}
    
    View the cloudtrail log in the AWS Console:`;

    var test = "";
    events.forEach(element => {
        console.log(element)
        elementMessage = JSON.parse(element.message)
        test = test + `
    
    - Event Name:${elementMessage.eventName}


    ${JSON.stringify(elementMessage, undefined, 4)}

       `
    });
    // https://${clouldTrail.awsRegion}.console.aws.amazon.com/cloudtrail/home?region=${clouldTrail.awsRegion}#/events/${elementMessage.eventID}\n
    customMessage = customMessage + test;

    return { message: customMessage, subject: `ALARM: "${alarm.AlarmName}" in ${clouldTrail.awsRegion}` };
}