function jahSendEmail(recipient, subject, message, attachment)
% Use this to send error messages to JamesHounshell@gmail.com
% Please do not abuse this dummy email as it is used to help me diagnose problems.
%%
recipient='jameshounshell@gmail.com';
subject='test';

sender='MachindoTest@gmail.com';
psswd='pzAhizIOzheyhfj34IXF';

setpref('Internet','E_mail',sender);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',sender);
setpref('Internet','SMTP_Password',psswd);
 
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

sendmail(recipient, subject);%, message, attachment
%%
my_default_email_address = 'MachindoTest@gmail.com';
my_username = 'f9f1940a578f575861f6a00cc0e5b495';
my_password = '4a1f6356b20c46f65340824148ff1965';
 
setpref('Internet','E_mail',my_default_email_address);
setpref('Internet','SMTP_Server','in-v3.mailjet.com');
setpref('Internet','SMTP_Username',my_username);
setpref('Internet','SMTP_Password',my_password);
 
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465'); %default port 465
sendmail('jameshounshell@gmail.com' , 'subject of the email', 'text of the email');