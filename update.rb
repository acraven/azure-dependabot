require "dependabot/omnibus"

package_manager = "nuget"
repo = "YOUR_ORG/YOUR_PROJECT/_git/YOUR_REPO"
directory = "."

credentials = [{
  "type" => "git_source",
  "host" => "dev.azure.com",
  "username" => "",
  "password" => ENV["SYSTEM_ACCESSTOKEN"]
},{
  "type" => "nuget_feed",
  "url" => "https://pkgs.dev.azure.com/YOUR_ORG/_packaging/YOUR_FEED/nuget/v3/index.json",
  "token" => ":#{ENV["SYSTEM_ACCESSTOKEN"]}"
}]

source = Dependabot::Source.new(
  provider: "azure",
  repo: repo,
  directory: directory
)

fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
  source: source,
  credentials: credentials,
)

files = fetcher.files
commit = fetcher.commit 

parser = Dependabot::FileParsers.for_package_manager(package_manager).new(
  dependency_files: files,
  source: source,
  credentials: credentials,
)

dependencies = parser.parse

dependencies.select(&:top_level?).each do |dep|
  puts "Found #{dep.name} @ #{dep.version}..."

  checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
    dependency: dep,
    dependency_files: files,
    credentials: credentials,
  )

  if checker.up_to_date?
    puts "  already using latest version"
    next
  end

  requirements_to_unlock =
    if !checker.requirements_unlocked_or_can_be?
      if checker.can_update?(requirements_to_unlock: :none) then :none
      else :update_not_possible
      end
    elsif checker.can_update?(requirements_to_unlock: :own) then :own
    elsif checker.can_update?(requirements_to_unlock: :all) then :all
    else :update_not_possible
    end

  next if requirements_to_unlock == :update_not_possible

  updated_deps = checker.updated_dependencies(
    requirements_to_unlock: requirements_to_unlock
  )

  puts "  considering upgrade to #{checker.latest_version}"
  updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
    dependencies: updated_deps,
    dependency_files: files,
    credentials: credentials,
  )

  updated_files = updater.updated_dependency_files

  pr_creator = Dependabot::PullRequestCreator.new(
    source: source,
    base_commit: commit,
    dependencies: updated_deps,
    files: updated_files,
    credentials: credentials,
    label_language: true,
    author_details: {
      email: "dependabot@YOUR_DOMAIN",
      name: "dependabot"
    },
  )

  pull_request = pr_creator.create

  if pull_request&.status == 201
    content = JSON[pull_request.body]

    puts "  PR ##{content["pullRequestId"]} submitted"
  else
    puts "  PR already exists or an error has occurred"
  end

  next unless pull_request
end