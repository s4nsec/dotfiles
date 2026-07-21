import type { Plugin } from "@opencode-ai/plugin"

export const NotificationPlugin: Plugin = async ({ client, $ }) => ({
  event: async ({ event }) => {
    if (event.type !== "session.idle") return

    try {
      const result = await client.session.get({
        path: { id: event.properties.sessionID },
      })
      if (result.error) throw new Error(JSON.stringify(result.error))
      if (!result.data) throw new Error("Session lookup returned no data")
      if (result.data.parentID) return

      const message = result.data.title
        ? `Agent finished: ${result.data.title}`
        : "Agent finished"

      const notification = await $`terminal-notifier -title OpenCode -message ${message} -sound default -group ${event.properties.sessionID}`
        .quiet()
        .nothrow()
      if (notification.exitCode !== 0) {
        throw new Error(notification.stderr.toString().trim())
      }
    } catch (error) {
      await client.app
        .log({
          body: {
            service: "notification",
            level: "error",
            message: "Notification delivery failed",
            extra: {
              error: error instanceof Error ? error.message : String(error),
            },
          },
        })
        .catch(() => {})
    }
  },
})
