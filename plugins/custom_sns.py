from airflow.providers.amazon.aws.hooks.sns import AwsSnsHook


def send_email(to, subject, html_content, files=None, dryrun=False, cc=None, bcc=None,
               mime_subtype='mixed', mime_charset='us-ascii', **kwargs):
    sns_hook = AwsSnsHook()
    subject_content = subject if(len(subject) <= 100) else subject[:97] + '...'
    sns_hook.publish_to_target(target_arn=to, message=html_content, subject=subject_content)
