require 'xcodeproj'

project = Xcodeproj::Project.open(ARGV.fetch(0))
apps = project.targets.select { |t| t.product_type == 'com.apple.product-type.application' }
abort 'Expected one Runner app target' unless apps.size == 1 && apps.first.name == 'Runner'
target = apps.first
root = File.dirname(File.expand_path(ARGV.fetch(0)))
expected = File.join(root, 'Runner', 'ios-daro-key.txt')
refs = project.files.select { |f| f.real_path.to_s == expected }
abort 'Duplicate key file references' if refs.size > 1
ref = refs.first
changed = false
unless ref
  ref = project.main_group.new_file('Runner/ios-daro-key.txt', 'SOURCE_ROOT')
  changed = true
end
unless target.resources_build_phase.files_references.include?(ref)
  target.resources_build_phase.add_file_reference(ref, true)
  changed = true
end
minimum = Gem::Version.new(ARGV.fetch(1))
(project.build_configurations + target.build_configurations).each do |config|
  value = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
  if value.nil? || Gem::Version.new(value) < minimum
    inherited = project.build_configurations.find { |entry| entry.name == config.name }&.build_settings&.fetch('IPHONEOS_DEPLOYMENT_TARGET', nil)
    required = inherited ? [minimum, Gem::Version.new(inherited)].max : minimum
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = required.to_s
    changed = true
  end
end
project.save if changed
