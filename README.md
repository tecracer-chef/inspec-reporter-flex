# inspec-reporter-flex Plugin

InSpec Flex reporter for freeform templating.

## To Install This Plugin

Inside InSpec:

```shell
you@machine $ inspec plugin install inspec-reporter-flex
```

For use within `kitchen`:

```shell
you@machine $ gem install inspec-reporter-flex
```

## How to use this plugin

To generate a report using this plugin and save the output to a file named `report.txt`, run:

```shell
you@machine $ inspec exec some_profile --reporter flex:/tmp/report.txt
```

## Configuring the Plugin

The `flex` reporter offers only one customization option:

For example:

```json
{
  "version": "1.2",
  "plugins": {
    "inspec-reporter-flex": {
      "template_file": "template/markdown.erb"
    }
  }
}
```

See below all customization options available:

| Option           |              Env Variable            |        Default       |  Description  |
|------------------|:------------------------------------:|:--------------------:|---------------|
| `template_file`  | `INSPEC_REPORTER_FLEX_TEMPLATE_FILE` | `templates/flex.erb` | Name of the file for templating. Will look up in order "absolute path", "relative to current directory", "relative to gem directory" |

## Writing Templates

Templates are written in the omnipresent ERB language, which might read like this:

```erb
<% profiles.each do |profile| %>
<%= profile.title %>:
<%   profile.controls.each do |control| %>
<%=    control.title %>:
<%     control.results.each do |result| %>
<%=      <%= result.status %>
<%    end %>
<%  end %>
<% end %>
```

### Variables

The following variables are passed to your template:

| Name            | Contents                                        |
| --------------- | ----------------------------------------------- |
| `profiles`      | Array of all profiles from the InSpec run       |
| `statistics`    | Statistics (e.g. runtime)                       |
| `platform`      | Platform information                            |
| `version`       | InSpec version used                             |
| `passed_tests`  | Number of passed tests                          |
| `failed_tests`  | Number of failed tests                          |
| `percent_pass`  | Percentage of passed tests                      |
| `percent_fail`  | Percentage of failed tests                      |
| `platform_arch` | Architecture of the platform (e.g. `x86_64`)    |
| `platform_name` | Full name of the platform (e.g. `Ubuntu Linux`) |

### Helpers

Some helper functions for easier template processing:

| Name                           | Returns    | Description                                   |
| ------------------------------ | ---------- | --------------------------------------------- |
| `scan_time`                    | `DateTime` | Roughly the time of scan end                  |
| `control_passed?(control)`     | `Boolean`  | If all results of the control are passed      |
| `status_to_pass(status)`       | `String`   | Translate to "ok"/not ok"                     |
| `impact_to_severity(severity)` | `String`   | Translate InSpec numeric severity to a string |

You also have the option of running some additional commands against the machine under test. This is sometimes needed for some metadata in reports.

Execution or InSpec resource related helpers:

| Name                                    | Returns             | Description                                                               |
| --------------------------------------- | ------------------- | ------------------------------------------------------------------------- |
| `remote_command(cmd)`                   | `CommandResult`     | Execute command (`.stdout`/`.stderr`/`.exit_status`)                      |
| `remote_file_content(remote_file)`      | `String`            | Contents of a file                                                        |
| `os`                                    | `os` resource       | OS information (`.arch`/`.family`/`.name`)                                |
| `sys_info`                              | `sys_info` resource | System Information (`.domain`/`.fqdn`/`.hostname`/`.ip_address`/`.model`) |
| `inspec_resource.*`                     | Any InSpec resource | Return value varies depending on the resource                             |

### Template-specific settings

You can add your own template-specific settings via the `template_config` hash in the ERB templates. Just add a block to read those and apply defaults like:

```ruby
<%
  config_emojis = template_config.fetch("emojis", true)
%>
```

You can configure these freeform settings in your `~/.inspec/config.json`:

```json
{
  "version": "1.2",
  "plugins": {
    "inspec-reporter-flex": {
      "template_config": {
        "emojis": true
      }
    }
  }
}
```

## Developing This Plugin

Submit PR and will discuss, thank you!
