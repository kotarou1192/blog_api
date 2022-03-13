# usage
# attached_file_type: { types: %w[image/png image/jpg image/jpeg image/gif] }
class AttachedFileTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true unless value.attached?
    return true unless options&.dig(:types)

    types = options[:types]
    attachments = value.is_a?(ActiveStorage::Attached::Many) ? value.attachments : [value.attachment]
    if attachments.any? { |attachment| !types.include? attachment.content_type }
      record.errors.add(attribute, :invalid_file_type)
    end
  end
end
