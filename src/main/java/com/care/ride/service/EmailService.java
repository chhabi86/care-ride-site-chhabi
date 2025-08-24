package com.care.ride.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.stereotype.Service;

import java.util.Properties;

@Service
public class EmailService {
    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    public void sendContactEmail(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("info@careridesolutionspa.com");
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);

        // If we have the implementation available, force envelope and debug properties at runtime
        if (mailSender instanceof JavaMailSenderImpl) {
            JavaMailSenderImpl impl = (JavaMailSenderImpl) mailSender;
            Properties props = impl.getJavaMailProperties();
            // Ensure envelope-from is the authenticated user / info@ address
            props.put("mail.smtp.from", "info@careridesolutionspa.com");
            props.put("mail.debug", "true");
            props.put("mail.smtp.auth", "true");
            // Log a snapshot of important mail config
            log.info("JavaMailSenderImpl in use. Host={}, Port={}, Username={}, props.mail.smtp.from={}",
                    impl.getHost(), impl.getPort(), impl.getUsername(), props.get("mail.smtp.from"));
        } else {
            log.info("JavaMailSender implementation is {}", mailSender.getClass().getName());
        }

        try {
            mailSender.send(message);
            log.info("Email sent to {} (subject={})", to, subject);
        } catch (Exception ex) {
            // Log full exception so we capture SMTP server reject messages
            log.error("Failed to send email to {} (subject={}). Exception: {}", to, subject, ex.toString(), ex);
            throw ex;
        }
    }
}
