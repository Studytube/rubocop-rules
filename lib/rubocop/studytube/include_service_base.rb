# frozen_string_literal: true

module RuboCop
  module Cop
    module Studytube
      # please include ServiceBase into a service class
      #
      # @example
      #   # bad
      #   class AnyService
      #     def self.call
      #     end
      #   end
      #
      #   # good
      #   class AnyService
      #     include ServiceBase
      #
      #     def call
      #     end
      #   end
      class IncludeServiceBase < Base
        extend AutoCorrector

        MSG = 'please include ServiceBase into a service class'

        def_node_search :include_declarations, '(send nil? :include (:const ... $_) ...)'
        def_node_matcher :super_class_declarations, '(class (const nil? _) (const ...) ...)'
        def_node_matcher :instance_call_declarations, '(def :call (args) nil?)'
        def_node_matcher :class_call_declarations, '(defs (self) :call (args) nil?)'

        def on_defs(node)
          class_node = class_node(node)

          return unless class_node
          return if super_class_declarations(class_node) # skip if class has parent declaration

          # `include ServiceBase` + `def self.call`
          if include_service_base?(class_node) && class_call_declarations(node) 
            add_offense(node, message: 'You have to use `def call`')
          end

          # no `include ServiceBase` + `self.call`
          if !include_service_base?(class_node) && class_call_declarations(node)
            add_offense(class_node) do |corrector|
              corrector.insert_after(class_node.child_nodes.first, "\n#{' ' * node.source_range.column}include ServiceBase")
              corrector.replace(node.child_nodes.first, '') # removes `self`
              corrector.replace(node.loc.operator, '') # removes `.`
            end
          end

        end

        def on_def(node)
          class_node = class_node(node)

          return unless class_node
          return if super_class_declarations(class_node) # skip if class has parent declaration

          # no `def call`
          return unless instance_call_declarations(node)

          # no `include ServiceBase`
          unless include_service_base?(class_node) 
            add_offense(class_node) do |corrector|
              corrector.insert_after(class_node.child_nodes.first, "\n#{' ' * node.source_range.column}include ServiceBase")
            end
          end
        end

        def include_service_base?(node)
          include_declarations(node).any? do |current|
            current.to_s.eql?('ServiceBase')
          end
        end

        def class_node(node)
          return unless node.parent.class_type? 
          
          node.parent
        end
      end
    end
  end
end
