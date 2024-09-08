export const kinesisHandler = async (event, context) => {
    console.log("Running from Lambda: " + new Date().toDateString())
    return {
        event
    }
}