# Terraformed Scalingo SI

## Pré-requis:

- Avoir terraform dans le PATH
- Avoir le provider scalingo compilé dans ~/.terraform.d/plugins/$ARCH/terraform-provider-scalingo
- Avoir créé un token d'API Scalingo (cf: https://developers.scalingo.com/index#authentication)

## Comment utiliser

*Plan*:
```
TF_VAR_apitoken=$scalingo_token terraform plan
```

*Apply*:
```
TF_VAR_apitoken=$scalingo_token terraform apply
```

Vous pouvez définir un environnement avec la variable d'environnment `TF_VAR_environement`.

