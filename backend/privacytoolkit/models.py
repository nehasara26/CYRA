from django.db import models
class PasswordEntry(models.Model):
    user_id = models.CharField(max_length=100)
    password = models.CharField(max_length=225)
    created_at = models.DateTimeField(auto_now_add=True)


# Create your models here.
