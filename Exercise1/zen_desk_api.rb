require 'net/http'
require 'rest_client'
require 'rexml/document'

# The class implements the functionality to perform basically 3 operations
#* Creates a user
#* Creates a ticket with that user as requester
#* Marks that ticket as solved
#
# It uses XML over HTTP to communicate to the zendesk API

class ZenDeskAPI

  include REXML

  attr_accessor :response
  attr_accessor :responsecode
  attr_accessor :hostname

  public
  def initialize(host, usrname, pswd)
    @hostname = host
    @username = usrname
    @password = pswd

  end

  # create the <user></user>xml document to be posted for creating the user
  def createuserxml(useremail, username, roleid, restrictionid, groupids)
    userxml = Document.new
    userxml.add_element("user")
    email = Element.new("email")
    email.text= useremail
    userxml.root.add_element(email)
    name = Element.new("name")
    name.text = username
    userxml.root.add_element(name)
    role = Element.new("roles")
    role.text = roleid
    userxml.root.add_element(role)
    restriction_id = Element.new("restriction_id")
    restriction_id.text = restrictionid
    userxml.root.add_element(restriction_id)
    groups = Element.new("groups")
    userxml.root.add_element(groups, {"type" => "array"})
    # we can have or more of the groupIds
    groupids.each { |groupid|
      group = Element.new("group")
      group.text = groupid
      groups.add_element(group)
    }

    return userxml # need to explicitly return in in this case because we want to return the entire xml we just built
  end

  # create the <ticket></ticket> xml for creating a ticket for a user
  def createticketxml(descriptiontext, priorityid, requesternametext, requesteremail)
    ticketxml = Document.new
    ticketxml.add_element("ticket")
    description = Element.new("description")
    description.text = descriptiontext
    ticketxml.root.add_element(description)
    priority = Element.new("priority-id")
    priority.text = priorityid
    ticketxml.root.add_element(priority)
    requestername = Element.new("requester-name")
    requestername.text = requesternametext
    ticketxml.root.add_element(requestername)
    email = Element.new("requester-email")
    email.text = requesteremail
    ticketxml.root.add_element(email)

    return ticketxml

  end

  # create the <ticket> xml to update the system with the new value of ticket
  # In this case we ned to update the status of the ticket as solved
  # need to update the status-id to 3 to indicate that the ticket has been
  # solved. The asigneed is is the id of a person who needs to be assigned this tikcetbefore it can be closed
  def createsolvedticketxml(assignee_id)

    closeticketxml = Document.new
    closeticketxml.add_element("ticket")
    assignee = Element.new("assignee-id")
    assignee.text = assignee_id
    closeticketxml.root.add_element(assignee)

    # id of a closed ticket is 3
    status = Element.new("status-id")
    status.text = 3
    closeticketxml.root.add_element(status)
    return closeticketxml # explict return to return the entire xml
  end

  # creates a Zen Desk user
  # the user can have the following roles 'End User', 'Administrator', Agent'
  # the corresponding ids for the above roles are 0 , 2, 4 respectively
  # restriction id denotes the restrictions for user or agents
  # the appropriate values for this field are [0, 1, 2, 3, 4]
  # we make the calls to the ZenDesk API using our administrator credentials
  # when it succeeds sets the response code and response in case of failure
  # raises RequestFailureException
  public
  def createuser(useremail, username, roleid, restrictionid, groupids)

    @valid_role_id = ["0", "2", "4"]
    @valid_restriction_id =["0", "1", "2", "3", "4"]

    raise ArgumentError.new ("No user email present") if useremail.empty?
    raise ArgumentError.new("No user name present") if username.empty?
    raise ArgumentError.new(" No role entered") if roleid.empty?
    raise ArgumentError.new(" invalid role id entered") if !@valid_role_id.include?(roleid)
    raise ArgumentError.new("invalid restriction id") if !@valid_restriction_id.include?(restrictionid)

    xml = createuserxml(useremail, username, roleid, restrictionid, groupids)

    begin
      resource = RestClient::Resource.new @hostname, @username, @password
      httpresponse = resource['/users.xml'].post xml.to_s, :content_type => 'application/xml', :accept => '*/*'
      processresponse(httpresponse) # call success handler
    rescue => e
      processerror(e) # call error handler
    end

  end

  # creates a zen desk ticket  after posting to the hostname/tickets.xml url
  # this API will create the username as specified in the requester email field
  # if it does not already there. Else it will create a ticket in the name o
  # requester email and request name as specified
  public
  def createticket(descriptiontext, priorityid, requesternametext, requesteremail)

    @valid_priority_id =["0","1","2","3","4"]

    raise ArgumentError.new("No requester email present") if requesteremail.empty?
    raise ArgumentError.new("No description text provided") if descriptiontext.empty?
    raise ArgumentError.new("Invalid priority id entered") if !@valid_priority_id.include?(priorityid)

    xml = createticketxml(descriptiontext, priorityid, requesternametext, requesteremail)

    begin
      resource = RestClient::Resource.new @hostname, @username, @password
      httpresponse = resource['/tickets.xml'].post xml.to_s, :content_type => 'application/xml', :accept => '*/*'
      processresponse(httpresponse) # call success handler

    rescue => e
      processerror(e) # call error handler
    end


  end

  # close a specified ticket as solved
  # we need to have an assignee id to close the ticket
  # call the underlying API(put) after constructing the xml with the assignee id and ticket id
  def solveticket(assigneeid, ticketidxml)

    raise ArgumentError.new("no assignee is present") if assigneeid.empty?
    raise ArgumentError.new("ticketid is present text provided") if  ticketidxml.empty?

    xml = createsolvedticketxml(assigneeid)

    begin
      resource = RestClient::Resource.new @hostname, @username, @password
      url = 'tickets/'+ ticketidxml
      httpresponse = resource[url].put xml.to_s, :content_type => 'application/xml', :accept => '*/*'
      processresponse(httpresponse) # call success handler
    rescue => e
      processerror(e) # call error handler
    end

  end

  # utility method to extract the name of the xml-file with the ids of the users, tickets etc
  # e.g give http://hostname/user/24.xml this will extract the string 24.xml
  def self.extractid(url)

    url.to_s.scan(/\d+\.xml/)[0]

  end

  # method that sets the success error code and text from the
  # HTTP response. In our case the information is avalable in the header
  def processresponse(httpresponse)

    @responsecode = httpresponse.code
    case httpresponse.code
      when 201 # success condition
        @response = httpresponse.headers[:location]
      when 200 # success condition
        @response = httpresponse.headers[:location]

    end

  end

  # handle the HTTP error conditions
  #we could build on this method in the futre to provide the clients of the API with more helpful
  #error messages
  def processerror(exception)
    case exception

      when RestClient::NotAcceptable #406
        raise RequestFailureException, "Request failure"
      when RestClient::Unauthorized #401
        raise RequestFailureException, "Unauthorized access"
      when RestClient::ResourceNotFound #404
        raise RequestFailureException, "Incorrect request parameters. Check your url and the input xml"
      when RestClient::InsufficientStorage # 507
        raise RequestFailureException, "Account is full.User cannot make any more requests"
      when RestClient::ServiceUnavailable # 503 => 'Service Unavailable',
        raise RequestFailureException, "Your API has been throttled for now. Please try again later"

      when ArgumentError
        raise exception

      else
        puts exception.message
        raise UnhandledException


    end

  end

end

# Our exception
#Handle exception more gracefully with more germane error codes
#typically we perhaps would use the request,db state etc
#to provide the client with more useful error message!!, logging etc
class RequestFailureException < RuntimeError

end


# unhandled exceptions by our code
class UnhandledException < RuntimeError

end