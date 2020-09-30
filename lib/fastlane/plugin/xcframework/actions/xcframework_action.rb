require 'fastlane/action'
require_relative '../helper/xcframework_helper'

module Fastlane
  module Actions
    class XcframeworkAction < Action
      def self.run(params)
        scheme = params[:scheme]        
        workspace = params[:workspace]
        derived_data_path = params[:derived_data_path] ||= '~/Library/Developer/Xcode/DerivedData'
        build_path = params[:build_path] ||= './Build'
        configuration = params[:configuration] ||= 'Release'

        # TODO: Allow platforms to be configurable
        platforms = {
          sim: 'generic/platform=iOS Simulator',
          device: 'generic/platform=iOS'
        }
        
        # 1. Archive for each platform separately
        platforms.each do |platform, destination|
          XcodebuildAction.run(
            archive: true,
            archive_path: "#{build_path}/Archive/#{scheme}_#{platform.to_s}",
            configuration: configuration,
            scheme: scheme,
            derived_data_path: derived_data_path,
            workspace: workspace,
            xcargs: "-destination \"#{destination}\" "\
            "SKIP_INSTALL=NO "\
            "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
          )
        end
        
        # 2. Create xcframework by combining built archives
        # TODO: There must be a better way to do all of this string magic
        framework_path = "/Products/Library/Frameworks/#{scheme}.framework"
        framework_flags = platforms.map do |platform, destination|
            "-framework #{build_path}/Archive/#{scheme}_#{platform.to_s}.xcarchive#{framework_path}"
        end
        output_flag = "-output \"#{build_path}/XCFramework/#{scheme}.xcframework\""
  
        command = [
          "xcodebuild -create-xcframework",
          framework_flags.join(" "),
          output_flag,
          "| xcpretty"
        ].join(" ")

        sh(command)
      end
      
      def self.description
        "A plugin to package .xcframework libraries"
      end
      
      def self.authors
        ["Balazs Toth"]
      end
      
      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end
      
      def self.details
        # Optional:
        ""
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :scheme,
            env_name: "XCFRAMEWORK_SCHEME",
            description: "The scheme to create the .xcframework archive from",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_path,
            env_name: "XCFRAMEWORK_BUILD_PATH",
            description: "The folder for the archives for each given platform",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :derived_data_path,
            env_name: "XCFRAMEWORK_DERIVED_DATA_PATH",
            description: "Derived data path to pass along to xcodebuild",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :workspace,
            env_name: "XCFRAMEWORK_WORKSPACE",
            description: "The xcworkspace that contains the give scheme",
            optional: true,
            type: String
          )
        ]
      end
      
      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
