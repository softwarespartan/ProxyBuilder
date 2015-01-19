%% Java Objects in Matlab
%

%% What are Java Class Objects?
% Think of 
% <http://docs.oracle.com/javase/8/docs/api/java/lang/Class.html Class> 
% objects as blueprint for creating instances.  
% Another way to think of objects of type Class is as a meta-object.  That is, class objects contain metadata information about an object such as 
%
% * name
% * methods
% * constructors
% * annotations
%
% and other various helper functions such as _isInterface()_ and _isAbstract()_ etc. 
%
% Typically, Class objects can be obtained by asking an instance for it's Class like this:

% create an instance of an ArrayList
list = java.util.ArrayList();

% ask the ArrayList instance for its Class
arrayListClass = list.getClass() 

%% 
% Using the Class object we can make queries about the ArrayList object such 

% what is the name of the package which contains ArrayList
pkg = arrayListClass.getPackage()

% figure out what methods the instance responds to
arrayListMethods = arrayListClass.getMethods()

%%
% And for the purposes of building proxy objects, we are particularly interested in interfaces

% figure out if the class implements any interfaces
interfaces = arrayListClass.getInterfaces()

%%
% Notice that when asking for interfaces we get back an array of Class objects, one for each interface implemented.  These Class objects will allow us to make queries about interfaces implmented.  For example

% print the names of each interface implemented by ArrayList
arrayfun(@(i)disp(i.getName()),interfaces)

%% 
% Similarly, it is straight forward to obtain the method signatures for all methods of ArrayList

% print out function signatures for all methods of ArrayList
arrayfun(@(m)disp(char(m.toGenericString())),arrayListMethods)

%%
% Finally, to actually instaciate an ArrayList instance (i.e. an actual ArrayList rather than metadata about an ArrayList) we can as the Class object to create one for us

% create instance of ArrayList using it's Class object
arrayList = arrayListClass.newInstance()

%%
% Authenticity can be verified using built-in Matlab function _isa_

% confirm arrayList is actually of type java.util.ArrayList 
isa(arrayList,'java.util.ArrayList')

%%
% and likewise, the verification in a very round about fashion which emphisizes use of the associated Class object 
strcmp('java.util.ArrayList',arrayList.getClass().getName())

%% Loading Java Classes in Matlab
%
% The first step in building a Java proxy is to load the Class blueprint.  Classes in Java can be listed on the static class path (loaded at launch) or the dynamic class path (loaded at runtime)
% However, loading Java Classes on the dynamic classpath in Matlab can be a little fickle.  
% 
% If the class to load is listed on Matlab's static class path ($matlabroot/toolbox/local/classpath.txt) then the simplest way to proceed is

% load class object for Java EventLister interface
cls = java.lang.Class.forName('java.awt.event.ActionListener')

%%
% Keep in mind this is a Class object for an ActionListener, not an instance.  With the ActionListener Class object we can verify that indeed this interface contains the actionPerformed method 

% print out methods declared by the ActionListener interface
arrayfun(@(m)disp(char(m.toGenericString())),cls.getDeclaredMethods())
  
%%
% Alternatively, can ask for the system class loader directly

% get system class loader
classLoader = java.lang.ClassLoader.getSystemClassLoader();

% load the Class object using a class loader
cls = classLoader.loadClass('java.awt.event.ActionListener')

%%
% Unfortunatly, the system ClassLoader in matlab is likewise restricted to the Java static classpath.  
%
% To load Classes on the dynamic classpath we can utilize special class loaders within *com.mathworks.jmi* package
%
% * com.mathworks.jmi.CustomURLClassLoader
% * com.mathworks.jmi.ClassLoaderManager
%
% and proceed as follows 

% add jar file dynamically (i.e. on the dynamic classpath)
javaaddpath('../ProxyBuilder.jar')

% get jmi class loader
classLoader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager()

% load Class for class defined in jar file
cls = classLoader.loadClass('com.mypkg.TestInterface')

%% References
%
% Java Doc:
%
% * <http://docs.oracle.com/javase/8/docs/api/java/lang/Class.html java.lang.Class> 
% * <http://docs.oracle.com/javase/8/docs/api/java/lang/ClassLoader.html java.lang.ClassLoader>
%
% * <http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/package-summary.html java.lang.reflect> 
% * <http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Method.html java.lang.reflect.Method>
%
% * <http://docs.oracle.com/javase/8/docs/api/java/util/ArrayList.html java.util.ArrayList>
%
% * <http://docs.oracle.com/javase/8/docs/api/java/util/List.html java.util.List>
% * <http://docs.oracle.com/javase/8/docs/api/java/util/RandomAccess.html java.util.RandomAccess>
% * <http://docs.oracle.com/javase/8/docs/api/java/lang/Cloneable.html java.lang.Clonable>
% * <http://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html java.io.Serializable>