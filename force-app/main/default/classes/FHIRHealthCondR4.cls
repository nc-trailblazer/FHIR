public inherited sharing class FHIRHealthCondR4 {
    public class Search_Z {
		public String mode {get;set;} 

		public Search_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'mode') {
							mode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Search_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Entry {
		public List<Link> link {get;set;} 
		public String fullUrl {get;set;} 
		public Resource resource {get;set;} 
		public Search_Z search_Z {get;set;} // in json: search

		public Entry(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'link') {
							link = arrayOfLink(parser);
						} else if (text == 'fullUrl') {
							fullUrl = parser.getText();
						} else if (text == 'resource') {
							resource = new Resource(parser);
						} else if (text == 'search') {
							search_Z = new Search_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Entry consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Category {
		public List<Coding_Z> coding {get;set;} 
		public String text {get;set;} 

		public Category(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'coding') {
							coding = arrayOfCoding_Z(parser);
						} else if (text == 'text') {
							text = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Category consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Coding {
		public String system_Z {get;set;} // in json: system
		public String version {get;set;} 
		public String code {get;set;} 
		public String display {get;set;} 

		public Coding(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'system') {
							system_Z = parser.getText();
						} else if (text == 'version') {
							version = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else if (text == 'display') {
							display = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Coding consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ClinicalStatus {
		public List<Coding> coding {get;set;} 
		public String text {get;set;} 

		public ClinicalStatus(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'coding') {
							coding = arrayOfCoding(parser);
						} else if (text == 'text') {
							text = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ClinicalStatus consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Coding_Y {
		public String system_Z {get;set;} // in json: system
		public String code {get;set;} 

		public Coding_Y(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'system') {
							system_Z = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Coding_Y consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Coding_Z {
		public String system_Z {get;set;} // in json: system
		public String code {get;set;} 
		public String display {get;set;} 

		public Coding_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'system') {
							system_Z = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else if (text == 'display') {
							display = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Coding_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Resource {
		public String resourceType {get;set;} 
		public String id {get;set;} 
		public ClinicalStatus clinicalStatus {get;set;} 
		public ClinicalStatus verificationStatus {get;set;} 
		public List<Category> category {get;set;} 
		public Code code {get;set;} 
		public Subject subject {get;set;} 
		public String recordedDate {get;set;} 

		public Resource(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'resourceType') {
							resourceType = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'clinicalStatus') {
							clinicalStatus = new ClinicalStatus(parser);
						} else if (text == 'verificationStatus') {
							verificationStatus = new ClinicalStatus(parser);
						} else if (text == 'category') {
							category = arrayOfCategory(parser);
						} else if (text == 'code') {
							code = new Code(parser);
						} else if (text == 'subject') {
							subject = new Subject(parser);
						} else if (text == 'recordedDate') {
							recordedDate = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Resource consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String resourceType {get;set;} 
	public String type_Z {get;set;} // in json: type
	public Integer total {get;set;} 
	public List<Link> link {get;set;} 
	public List<Entry> entry {get;set;} 

	public FHIRHealthCondR4(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'resourceType') {
						resourceType = parser.getText();
					} else if (text == 'type') {
						type_Z = parser.getText();
					} else if (text == 'total') {
						total = parser.getIntegerValue();
					} else if (text == 'link') {
						link = arrayOfLink(parser);
					} else if (text == 'entry') {
						entry = arrayOfEntry(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'FHIRHealthCondR4 consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Code {
		public List<Coding_Y> coding {get;set;} 
		public String text {get;set;} 

		public Code(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'coding') {
							coding = arrayOfCoding_Y(parser);
						} else if (text == 'text') {
							text = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Code consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Link {
		public String relation {get;set;} 
		public String url {get;set;} 

		public Link(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'relation') {
							relation = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Link consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Subject {
		public String reference {get;set;} 
		public String display {get;set;} 

		public Subject(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'reference') {
							reference = parser.getText();
						} else if (text == 'display') {
							display = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Subject consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static FHIRHealthCondR4 parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new FHIRHealthCondR4(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	





    private static List<Coding_Y> arrayOfCoding_Y(System.JSONParser p) {
        List<Coding_Y> res = new List<Coding_Y>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Coding_Y(p));
        }
        return res;
    }


    private static List<Link> arrayOfLink(System.JSONParser p) {
        List<Link> res = new List<Link>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Link(p));
        }
        return res;
    }






    private static List<Category> arrayOfCategory(System.JSONParser p) {
        List<Category> res = new List<Category>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Category(p));
        }
        return res;
    }



    private static List<Coding> arrayOfCoding(System.JSONParser p) {
        List<Coding> res = new List<Coding>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Coding(p));
        }
        return res;
    }


    private static List<Coding_Z> arrayOfCoding_Z(System.JSONParser p) {
        List<Coding_Z> res = new List<Coding_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Coding_Z(p));
        }
        return res;
    }




    private static List<Entry> arrayOfEntry(System.JSONParser p) {
        List<Entry> res = new List<Entry>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Entry(p));
        }
        return res;
    }

}
