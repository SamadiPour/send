# Send - Flutter Deployment Tool Documentation

Welcome to the Send documentation! Send is a comprehensive deployment automation tool designed
specifically for Flutter applications, streamlining deployment to both Android (Google Play) and
iOS (App Store).

## Quick Start

1. **Installation**: Add Send to your Flutter project
2. **Configuration**: Set up your `deploy.yaml` file
3. **Platform Setup**: Configure Android and/or iOS credentials
4. **Deploy**: Run Send to deploy your app

## Security Best Practices

### Credential Management

1. **Never commit credentials to version control**
2. **Use secure storage for CI/CD environments**
3. **Limit permissions to minimum required access**

### Recommended .gitignore entries:

```gitignore
# Deployment credentials
credentials/
private_keys/
*.p8
```

## CI/CD Integration

Send is designed to work seamlessly with any CI/CD platform:

- **GitHub Actions**
- **GitLab CI**
- **Azure DevOps**
- **Jenkins**
- **CircleCI**
- **Travis CI**

### Environment Variables

For CI/CD environments, you can use environment variables instead of files:

```bash
export ANDROID_CREDENTIALS_JSON="$(cat service-account.json)"
export IOS_PRIVATE_KEY="$(cat AuthKey_XXXXXXXXXX.p8)"
```

## Troubleshooting

### Common Issues

1. **Build failures**: Ensure `flutter build` commands work locally
2. **Authentication errors**: Verify credential file paths and permissions
3. **Version conflicts**: Check version codes/numbers are properly incremented
4. **Platform-specific errors**: Refer to platform-specific setup guides

### Debug Commands

```bash
# Validate Flutter setup
flutter doctor

# Test Android build
flutter build appbundle --release

# Test iOS build (macOS only)
flutter build ios --release
```

## Support and Contributing

### Best Practices

1. **Test locally first**: Always ensure `flutter build` works before deployment
2. **Use internal tracks**: Test with internal/alpha tracks before production
3. **Monitor releases**: Check App Store Connect and Google Play Console for issues
4. **Version management**: Use semantic versioning and proper build numbers

---

**Next Steps:**

- Follow the [Android Setup Guide](android-setup.md) for Google Play deployment
- Follow the [iOS Setup Guide](ios-setup.md) for App Store deployment
- Configure your `deploy.yaml` file
