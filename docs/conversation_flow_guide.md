# Conversation Flow Configuration Guide

This guide explains how to modify and maintain the conversation flow in Tina using the Dart-driven configuration system.

## 📁 File Structure

```
lib/config/
├── conversation_flow_data.dart    # Main configuration file
lib/features/conversation/
├── services/
│   └── conversation_flow_loader.dart    # Loads Dart configuration
├── model/
│   └── conversation_flow_config.dart    # Configuration access
scripts/
└── validate_conversation_flow.dart      # Validation script
test/
└── conversation_flow_test.dart          # Comprehensive tests
```

## 🎯 Quick Start

### Modifying Questions

1. **Edit the Dart file**: `lib/config/conversation_flow_data.dart`
2. **Validate changes**: `dart scripts/validate_conversation_flow.dart`
3. **Run tests**: `flutter test test/conversation_flow_test.dart`
4. **Hot reload**: Your changes will be reflected immediately!

### Example: Changing a Question

```dart
// Before
{
  'id': 'welcome',
  'question_text': 'היי! אני פה לעזור לך עם שיחה.',
  // ... other fields
}

// After  
{
  'id': 'welcome',
  'question_text': 'שלום! איך אוכל לעזור לך היום?',
  // ... other fields
}
```

## 📝 Dart Configuration Reference

### Basic Step Structure

```dart
{
  'id': 'step_name',                    // Unique identifier
  'question_text': '''Multi-line text  // The question to ask
is supported using triple quotes''',
  'hint_text': 'Input placeholder',     // Optional
  'target_field': 'fieldName',          // Where to store answer
  'is_optional': false,                 // Can user skip?
  'skip_keywords': ['דלג', 'אין'],      // Words that trigger skip
  'next_step_id': 'next_step',          // Next step in flow
  'completion_messages': {              // Optional final messages
    'with_answer': 'Thanks message',
    'without_answer': 'Default message',
  },
}
```

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique step identifier | `welcome` |
| `question_text` | String | Question to display | `מה השם שלך?` |
| `target_field` | String | Data field to store answer | `task` |

### Valid Target Fields

- `task` - Main task description
- `contactPhone` - Contact information  
- `identifyingDetails` - Additional details

### Optional Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `hint_text` | String | Input placeholder | `null` |
| `is_optional` | Boolean | Can be skipped | `false` |
| `skip_keywords` | List<String> | Skip trigger words | `[]` |
| `next_step_id` | String | Next step | `null` |
| `completion_messages` | Map | End messages | `null` |

## 🔧 Common Modifications

### 1. Adding a New Question

```yaml
conversation_flow:
  steps:
    - id: welcome
      question_text: הודעת פתיחה
      target_field: task
      next_step_id: priority  # ← Point to new step
      
    - id: priority           # ← New step
      question_text: מה רמת הדחיפות?
      hint_text: רגיל / דחוף / קריטי
      target_field: priority
      next_step_id: contact   # ← Continue to existing step
      
    - id: contact
      # ... existing step
```

### 2. Reordering Steps

Simply change the `next_step_id` references:

```yaml
# Original: welcome → contact → details
# New order: welcome → details → contact

- id: welcome
  next_step_id: details    # ← Changed from 'contact'
  
- id: details  
  next_step_id: contact    # ← Changed from 'complete'
  
- id: contact
  next_step_id: complete   # ← Added
```

### 3. Making a Step Optional

```yaml
- id: details
  question_text: פרטים נוספים?
  target_field: identifyingDetails
  is_optional: true        # ← Make optional
  skip_keywords:           # ← Add skip words
    - דלג
    - אין
    - לא
  completion_messages:     # ← Different messages
    with_answer: תודה על הפרטים!
    without_answer: בסדר, נמשיך בלי פרטים.
```

### 4. Removing a Step

1. Delete the step from YAML
2. Update `next_step_id` references that pointed to it
3. Update target code if it used that step's data

## ✅ Validation & Testing

### Automated Validation

```bash
# Validate YAML configuration
dart scripts/validate_conversation_flow.dart

# Run comprehensive tests  
flutter test test/conversation_flow_test.dart

# Check specific test group
flutter test test/conversation_flow_test.dart --name "Configuration Validation"
```

### Validation Checks

The system validates:

- ✅ **File Structure**: Valid YAML format
- ✅ **Required Fields**: All steps have necessary data
- ✅ **Flow Logic**: No broken references or circular loops  
- ✅ **Data Quality**: Meaningful questions and hints
- ✅ **Language**: Hebrew text validation
- ✅ **Consistency**: Skip keywords and optional steps

### Example Validation Output

```
🔍 Validating conversation flow configuration...

✅ Conversation flow configuration is valid!
📊 Summary:
   • 3 steps configured
   • Flow: welcome → contact → details → complete
   • Optional steps: 1
```

## 🚨 Error Handling

### Common Errors & Solutions

#### 1. Missing Required Field
```
❌ Step welcome: Missing or empty "target_field" field
```
**Solution**: Add `target_field: fieldName` to the step

#### 2. Invalid Flow Reference
```
❌ Step welcome: References non-existent step "nonexistent"
```
**Solution**: Update `next_step_id` to point to valid step

#### 3. Circular Reference
```
❌ Circular reference detected starting from step: welcome  
```
**Solution**: Check `next_step_id` chain doesn't loop back

#### 4. Invalid Target Field
```
❌ Step welcome: Invalid target_field "invalid". Must be one of: [task, contactPhone, identifyingDetails]
```
**Solution**: Use one of the valid target fields

### Debugging Tips

1. **Use validation script**: Always run validation before testing
2. **Check console logs**: Look for specific error messages
3. **Test incrementally**: Make small changes and validate each one
4. **Use fallback**: If YAML fails, the system throws descriptive errors

## 🎨 Best Practices

### 1. Question Writing
- Use clear, concise Hebrew text
- Include context and examples when helpful
- Keep questions focused on one piece of information

### 2. Flow Design  
- Start with essential information first
- Group related questions together
- Minimize the number of steps
- Make non-essential steps optional

### 3. Hint Text
- Provide helpful examples: `מספר טלפון או אימייל`
- Keep hints short and relevant
- Use placeholder format: `הקלד כאן...`

### 4. Skip Keywords
- Use common Hebrew skip words: `דלג`, `אין`, `לא`
- Be consistent across optional steps
- Consider variations: `אין לי`, `לא יודע`

### 5. Data Mapping
- Choose appropriate `target_field` for each question
- Consider adding new fields for new data types
- Document data usage in comments

## 📊 Advanced Features

### Conditional Logic (Future Enhancement)

The YAML structure supports future conditional flows:

```yaml
# Future feature - conditional flows
conditional_flows:
  - condition: "answer contains 'דחוף'"
    from_step: welcome  
    to_step: priority_contact
    
  - condition: "answer contains 'ביטוח'"
    from_step: task
    to_step: insurance_details
```

### Validation Rules (Future Enhancement)

```yaml
# Future feature - input validation
validation_rules:
  - step_id: contact
    rule: phone_number
    error_message: אנא הזן מספר טלפון תקין
    
  - step_id: task  
    rule: min_length_10
    error_message: אנא הוסף תיאור מפורט יותר
```

## 🔄 Development Workflow

### Making Changes

1. **Edit YAML**: Modify `assets/config/conversation_flow.yaml`
2. **Validate**: Run `dart scripts/validate_conversation_flow.dart`
3. **Test**: Run `flutter test test/conversation_flow_test.dart`  
4. **Manual Test**: Test in the app with hot reload
5. **Commit**: Save changes when satisfied

### Testing Strategy

1. **Unit Tests**: Comprehensive YAML validation tests
2. **Integration Tests**: Test with actual conversation flow
3. **Manual Testing**: User experience validation
4. **Edge Cases**: Test skip flows, optional steps, errors

### Version Control

- Include YAML changes in pull requests
- Document flow changes in commit messages
- Test configuration changes before merging

## 🎯 Example Configurations

### Minimal Configuration

```yaml
conversation_flow:
  steps:
    - id: welcome
      question_text: מה אוכל לעזור?
      target_field: task
      next_step_id: complete
```

### Complete Configuration

```yaml
conversation_flow:
  steps:
    - id: welcome
      question_text: |
        היי! אני טינה, העוזרת הדיגיטלית.
        איך אוכל לעזור לך היום?
      hint_text: תיאור המשימה...
      target_field: task
      next_step_id: priority
      
    - id: priority
      question_text: מה רמת הדחיפות של הבקשה?
      hint_text: רגיל / דחוף / קריטי
      target_field: priority
      next_step_id: contact
      
    - id: contact
      question_text: איך אפשר ליצור איתך קשר?
      hint_text: מספר טלפון או אימייל
      target_field: contactPhone
      next_step_id: details
      
    - id: details
      question_text: |
        יש פרטים נוספים שיעזרו לי?
        למשל מספר לקוח או פוליסה
        
        (אפשר לכתוב 'דלג' אם אין)
      hint_text: פרטים מזהים (אופציונלי)
      target_field: identifyingDetails
      is_optional: true
      skip_keywords:
        - דלג
        - אין
        - לא
        - אין לי
      next_step_id: complete
      completion_messages:
        with_answer: |
          מעולה! הפרטים יעזרו לי בשיחה.
          אני מתחילה עכשיו...
        without_answer: |
          בסדר, אני מתחילה בלי פרטים נוספים.
          זה יהיה בסדר!
```

---

## 🆘 Need Help?

- **Validation Issues**: Run the validation script for specific errors
- **Test Failures**: Check the test output for detailed failure reasons  
- **Flow Logic**: Use the validation summary to understand current flow
- **YAML Syntax**: Validate YAML structure with online validators

The YAML-driven conversation flow makes it easy to modify Tina's conversation without touching any Dart code! 🚀 