ExceptionNotifier.exception_recipients = [Enki::Config.default[:author, :email]]
ExceptionNotifier.sender_address = Enki::Config.default[:author, :email]
ExceptionNotifier.email_prefix = "[AgileDisciple] "
