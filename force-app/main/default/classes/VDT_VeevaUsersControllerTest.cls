@IsTest
public with sharing class VDT_VeevaUsersControllerTest {

    @IsTest
    static void shouldReturnFirstFiveUsers() {
        insertUsers(10);
        Test.startTest();
        List<VDT_VeevaUsersController.UserWrapper> users = VDT_VeevaUsersController.fetchVeevaUsers(5, 0);
        Test.stopTest();
        System.assert(!users.isEmpty());
        System.assertEquals(5, users.size());

    }

    private static List<User> insertUsers(Integer totalRecords) {
        List<User> users = new List<User>();
        for (Integer c = 0; c < totalRecords; c++) {
            User newUser = new VDT_UserDataFactory()
                .name('Test#' + c)
                .username('base+'+ c +'user@testing.com')
                .alias('testU_' + c)
                .email('base+'+ c +'user@testing.com')
                .buildAdmin();
            users.add(newUser);
        }
        if (!users.isEmpty()) {
            insert users;
        }
        return users;
    }
}